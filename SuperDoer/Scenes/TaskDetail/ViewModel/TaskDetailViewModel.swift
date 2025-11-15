import Foundation
import RxCocoa
import RxRelay
import RxSwift

final class TaskDetailViewModel: TaskDetailViewModelInput, TaskDetailViewModelOutput,
                                 TaskDetailNavigationEmittable, TaskDetailCoordinatorResultHandler {

    private let disposeBag = DisposeBag()

    // TODO: - Services

    private let taskEm: TaskCoreDataManager
    private let taskFileEm: TaskFileEntityManager

    // MARK: - Model

    private let taskId: UUID
    private var task: CDTask?

    // MARK: - State

    private let tableViewModel: TaskDetailTableViewModel = .init()

    private let titleRelay = BehaviorRelay<String>(value: "")
    private let isCompletedRelay = BehaviorRelay<Bool>(value: false)
    private let isPriorityRelay = BehaviorRelay<Bool>(value: false)
    private let fieldEditingStateRelay = BehaviorRelay<TaskDetailViewModelFieldEditingState?>(value: nil)

    // MARK: - Output (properties)

    var titleDriver: Driver<String> { titleRelay.asDriver() }
    var isCompletedDriver: Driver<Bool> { isCompletedRelay.asDriver() }
    var isPriorityDriver: Driver<Bool> { isPriorityRelay.asDriver() }
    var fieldEditingStateDriver: Driver<TaskDetailViewModelFieldEditingState?> {
        // TODO: reentrancy!
        fieldEditingStateRelay.distinctUntilChanged().asDriver(onErrorJustReturn: nil)
    }
    var tableUpdateSignal: Signal<TaskDetailTableViewModel.UpdateEvent> {
        tableViewModel.updateEvent
    }
    var countSections: Int { tableViewModel.countSections }

    // MARK: - Input

    let inputEvent = PublishRelay<TaskDetailViewModelInputEvent>()

    // MARK: - Navigation

    private let navigationEventRelay = PublishRelay<TaskDetailNavigationEvent>()
    var navigationEvent: Signal<TaskDetailNavigationEvent> {
        navigationEventRelay.asSignal()
    }

    let coordinatorResult = PublishRelay<TaskDetailCoordinatorResult>()

    // MARK: - Init

    init(
        taskId: UUID,
        taskEm: TaskCoreDataManager,
        taskFileEm: TaskFileEntityManager
    ) {
        self.taskId = taskId
        self.taskEm = taskEm
        self.taskFileEm = taskFileEm

        setupBindings()
    }

    // MARK: - Output (methods)

    func getCountRowsInSection(_ sectionIndex: Int) -> Int {
        return tableViewModel.getCountRowsInSection(sectionIndex)
    }

    func getTableCellViewModel(for indexPath: IndexPath) -> TaskDetailTableCellViewModelType? {
        return tableViewModel.getCellVM(for: indexPath)
    }

    func canDeleteCell(with indexPath: IndexPath) -> Bool {
        return tableViewModel.getCellVM(for: indexPath) is FileCellViewModel
    }

    // MARK: - Setup

    private func setupBindings() {
        inputEvent.subscribe(onNext: { [weak self] event in
            self?.handleInputEvent(event)
        })
        .disposed(by: disposeBag)

        coordinatorResult.subscribe(onNext: { [weak self] event in
            self?.handleCoordinatorResultEvent(event)
        })
        .disposed(by: disposeBag)
    }

    // MARK: - Actions handlers

    private func handleCoordinatorResultEvent(_ event: TaskDetailCoordinatorResult) {
        switch event {
        case .didEnteredDescriptionEditorContent(let text):
            updateTaskField(descriptionText: text)

        case .didImportedImage(let imageData):
            imageData.map { self.createTaskFile(from: $0) }

        case .didImportedFile(let fileUrl):
            fileUrl.map { self.createTaskFile(from: $0) }

        case .didDeleteTaskFileConfirmed(let taskFile):
            deleteTaskFile(deletableVM: taskFile)

        case .didDeleteTaskFileCanceled:
            break

        case .didSelectDeadlineDate(let date):
            updateTaskField(deadlineDate: date)

        case .didSelectReminderDateTime(let dateTime):
            updateTaskField(reminderDateTime: dateTime)

        case .didSelectRepeatPeriodValue(let repeatPeriod):
            updateTaskField(repeatPeriod: repeatPeriod)
        }
    }

    // swiftlint:disable cyclomatic_complexity
    private func handleInputEvent(_ event: TaskDetailViewModelInputEvent) {
        switch event {
        case .needLoadInitialData:
            loadInitialData()

        case .didTapOpenReminderDateSetter:
            navigationEventRelay.accept(.openReminderDateSetter(dateTime: task?.reminderDateTime))

        case .didTapOpenDeadlineDateSetter:
            guard let task else { return }
            navigationEventRelay.accept(.openDeadlineDateSetter(deadlineAt: task.deadlineDate))

        case .didTapOpenRepeatPeriodSetter:
            navigationEventRelay.accept(
                .openRepeatPeriodSetter(repeatPeriod: task?.repeatPeriodStruct)
            )

        case .didTapAddFile:
            navigationEventRelay.accept(.openAddFile)

        case .didTapFileDelete(indexPath: let indexPath):
            handleTapFileDelete(with: indexPath)

        case .didTapOpenDescriptionEditor:
            handleTapOpenDescriptionEditor()

        case .didTapResetValueInMyDay:
            updateTaskField(inMyDay: false)

        case .didTapResetValueReminderDate:
            updateTaskField(reminderDateTime: nil)

        case .didTapResetValueDeadlineDate:
            updateTaskField(deadlineDate: nil)

        case .didTapResetValueRepeatPeriod:
            updateTaskField(repeatPeriod: nil)

        case .didChangeIsCompleted(let newValue):
            updateTaskField(isCompleted: newValue)

        case .didChangeIsPriority(let newValue):
            updateTaskField(isPriority: newValue)

        case .didBeginTaskTitleEditing:
            fieldEditingStateRelay.accept(.taskTitleEditing)

        case .didEndTaskTitleEditing(let newValue):
            updateTaskField(title: newValue)
            fieldEditingStateRelay.accept(nil)

        case .didTapTextEditingReadyBarButton:
            fieldEditingStateRelay.accept(nil)

        case .didToggleValueInMyDay:
            toggleValueTaskFieldInMyDay()
        }
    }
    // swiftlint:enable cyclomatic_complexity

    private func handleTapOpenDescriptionEditor() {
        guard let task else { return }
        let editorData = TextEditorData(
            text: task.descriptionTextAttributed,
            title: task.title
        )
        navigationEventRelay.accept(
            .openDescriptionEditor(editorData)
        )
    }

    private func handleTapFileDelete(with indexPath: IndexPath) {
        guard let cellVM = tableViewModel.getCellVM(for: indexPath),
              let fileCellVM = cellVM as? FileCellViewModel else { return }

        let fileDeletable =  TaskFileDeletableViewModel(
            title: fileCellVM.titleForDelete,
            indexPath: indexPath
        )

        navigationEventRelay.accept(.openDeleteFileConfirmation(fileDeletable))
    }

    // MARK: - Fetching Data

    private func loadInitialData() {
        guard let task = taskEm.getTaskBy(id: taskId) else { return }

        self.task = task
        titleRelay.accept(task.titlePrepared)
        isCompletedRelay.accept(task.isCompleted)
        isPriorityRelay.accept(task.isPriority)

        tableViewModel.refill(from: task)
    }

    // MARK: - Model manipulations

    private func updateTaskField(title: String?) {
        guard let task else { return }
        taskEm.updateField(title: title, task: task)
        titleRelay.accept(task.titlePrepared)
    }

    private func updateTaskField(isCompleted: Bool) {
        guard let task else { return }
        taskEm.updateField(isCompleted: isCompleted, task: task)
        isCompletedRelay.accept(task.isCompleted)
    }

    private func updateTaskField(isPriority: Bool) {
        guard let task else { return }
        taskEm.updateField(isPriority: isPriority, task: task)
        isPriorityRelay.accept(task.isPriority)
    }

    private func updateTaskField(inMyDay: Bool) {
        guard let task else { return }
        taskEm.updateField(inMyDay: inMyDay, task: task)
        tableViewModel.updateAddToMyDay(task.inMyDay)
    }

    private func toggleValueTaskFieldInMyDay() {
        guard let task else { return }
        let newValue = !task.inMyDay
        updateTaskField(inMyDay: newValue)
    }

    private func updateTaskField(deadlineDate: Date?) {
        guard let task else { return }
        taskEm.updateField(deadlineDate: deadlineDate, task: task)

        tableViewModel.updateDeadlineAt(task.deadlineDate)
    }

    private func updateTaskField(reminderDateTime: Date?) {
        guard let task else { return }
        taskEm.updateField(reminderDateTime: reminderDateTime, task: task)

        tableViewModel.updateReminderDate(task.reminderDateTime)
    }

    private func updateTaskField(repeatPeriod: TaskRepeatPeriod?) {
        guard let task else { return }
        taskEm.updateField(repeatPeriod: repeatPeriod, task: task)

        tableViewModel.updateRepeatPeriod(task.repeatPeriodStruct)
    }

    private func updateTaskField(descriptionText: NSAttributedString?) {
        guard let task else { return }

        taskEm.updateFields(
            descriptionText: descriptionText,
            descriptionUpdatedAt: Date(),
            task: task
        )

        tableViewModel.updateDescription(
            text: task.descriptionTextAttributed,
            updatedAt: task.descriptionUpdatedAt
        )
    }

    private func createTaskFile(from imageData: Data) {
        guard let task else { return }

        let nsImageData = NSData(data: imageData)
        let taskFile = taskFileEm.createWith(
            fileName: "Фото размером \(nsImageData.count) kb",
            fileExtension: "jpg",
            fileSize: nsImageData.count,
            task: task
        )

        tableViewModel.addFileCellVM(taskFile)
    }

    private func createTaskFile(from url: URL) {
        guard let task else { return }

        let taskFile = taskFileEm.createWith(
            fileName: "Файл размером ??? kb",
            fileExtension: url.pathExtension,
            fileSize: 0,
            task: task
        )

        tableViewModel.addFileCellVM(taskFile)
    }

    private func deleteTaskFile(deletableVM: TaskFileDeletableViewModel) {
        guard let task, let indexPath = deletableVM.indexPath else { return }

        let cellVM = tableViewModel.getCellVM(for: indexPath)
        guard let fileCellVM = cellVM as? FileCellViewModel else {
            // TODO: показать сообщение об ошибке (файл не получилось удалить)
            return
        }

        let taskFile = task.getFileBy(id: fileCellVM.id)
        guard let taskFile else {
            // TODO: показать сообщение об ошибке (файл не получилось удалить)
            return
        }

        taskFileEm.delete(file: taskFile)
        tableViewModel.deleteFile(with: indexPath)
    }

}
