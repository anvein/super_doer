import Foundation
import RxCocoa
import RxRelay
import RxSwift

// swiftlint:disable type_body_length
final class TaskDetailViewModel: TaskDetailViewModelInput, TaskDetailViewModelOutput,
    TaskDetailNavigationEmittable, TaskDetailCoordinatorResultHandler {

    private let disposeBag = DisposeBag()

    // TODO: - Services

    private let taskRepository: TaskRepository

    // MARK: - Model

    private let taskId: UUID
    private var task: TaskEntity?

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

    init(taskId: UUID, taskRepository: TaskRepository) {
        self.taskId = taskId
        self.taskRepository = taskRepository

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

    private func handleInputEvent(_ event: TaskDetailViewModelInputEvent) {
        switch event {
        case .needLoadInitialData:
            loadInitialData()

        case .didTapOpenReminderDateSetter:
            guard let task else { return }
            navigationEventRelay.accept(.openReminderDateSetter(dateTime: task.reminderDateTime))

        case .didTapOpenDeadlineDateSetter:
            guard let task else { return }
            navigationEventRelay.accept(.openDeadlineDateSetter(deadlineAt: task.deadlineDate))

        case .didTapOpenRepeatPeriodSetter:
            navigationEventRelay.accept(
                .openRepeatPeriodSetter(repeatPeriod: task?.repeatPeriod)
            )

        case .didTapAddFile:
            navigationEventRelay.accept(.openAddFile)

        case .didTapFileDelete(let indexPath):
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

    private func handleTapOpenDescriptionEditor() {
        guard let task else { return }
        let editorData = TextEditorData(
            text: task.descriptionText,
            title: task.title
        )
        navigationEventRelay.accept(
            .openDescriptionEditor(editorData)
        )
    }

    private func handleTapFileDelete(with indexPath: IndexPath) {
        guard let cellVM = tableViewModel.getCellVM(for: indexPath),
            let fileCellVM = cellVM as? FileCellViewModel,
            case .data(let fileData) = fileCellVM.state
        else {
            // TODO: показать alert что не получится удалить файл
            return
        }

        let fileDeletable = TaskFileDeletableViewModel(
            title: fileData.titleForDelete,
            indexPath: indexPath
        )

        navigationEventRelay.accept(.openDeleteFileConfirmation(fileDeletable))
    }

    // MARK: - Fetching Data

    private func loadInitialData() {
        let task = try? taskRepository.getTask(by: taskId)

        guard let task else {
            // TODO: не удалось загрузить задачу
            return
        }

        self.task = task
        titleRelay.accept(task.title)
        isCompletedRelay.accept(task.isCompleted)
        isPriorityRelay.accept(task.isPriority)

        tableViewModel.refill(from: task)
    }

    // MARK: - Model manipulations

    private func updateTaskField(title: String?) {
        do {
            let task = try taskRepository.updateField(.title(title), taskId: taskId)
            self.task = task
            titleRelay.accept(task.title)
        } catch {
            // показать ошибку
            // откатить UI
        }
    }

    private func updateTaskField(isCompleted: Bool) {
        do {
            let task = try taskRepository.updateField(.isCompleted(isCompleted), taskId: taskId)
            self.task = task
            isCompletedRelay.accept(task.isCompleted)
        } catch {
            // показать ошибку
            // откатить UI
        }
    }

    private func updateTaskField(isPriority: Bool) {
        do {
            let task = try taskRepository.updateField(.isPriority(isPriority), taskId: taskId)
            self.task = task
            isPriorityRelay.accept(task.isPriority)
        } catch {
            // показать ошибку
            // откатить UI
        }
    }

    private func updateTaskField(inMyDay: Bool) {
        do {
            let task = try taskRepository.updateField(.inMyDay(inMyDay), taskId: taskId)
            self.task = task
            tableViewModel.updateAddToMyDay(task.isInMyDay)
        } catch {
            // показать ошибку
            // откатить UI
        }
    }

    private func toggleValueTaskFieldInMyDay() {
        guard let task else { return }
        let newValue = !task.isInMyDay
        updateTaskField(inMyDay: newValue)
    }

    private func updateTaskField(deadlineDate: Date?) {
        do {
            let task = try taskRepository.updateField(.deadlineDate(deadlineDate), taskId: taskId)
            self.task = task
            tableViewModel.updateDeadlineAt(task.deadlineDate)
        } catch {
            // показать ошибку
            // откатить UI
        }
    }

    private func updateTaskField(reminderDateTime: Date?) {
        do {
            let task = try taskRepository.updateField(.reminderDateTime(reminderDateTime), taskId: taskId)
            self.task = task
            tableViewModel.updateReminderDate(reminderDateTime)
        } catch {
            // показать ошибку
            // откатить UI
        }
    }

    private func updateTaskField(repeatPeriod: TaskRepeatPeriod?) {
        do {
            let task = try taskRepository.updateField(.repeatPeriod(repeatPeriod), taskId: taskId)
            self.task = task
            tableViewModel.updateRepeatPeriod(task.repeatPeriod)
        } catch {
            // показать ошибку
            // откатить UI
        }
    }

    private func updateTaskField(descriptionText: NSAttributedString?) {
        do {
            let task = try taskRepository.updateField(.description(descriptionText), taskId: taskId)
            self.task = task

            tableViewModel.updateDescription(
                text: task.descriptionText,
                updatedAt: task.descriptionUpdatedAt
            )
        } catch {
            // показать ошибку
            // откатить UI
        }
    }

    private func createTaskFile(from imageData: Data) {
        let nsImageData = NSData(data: imageData)

        do {
            let result = try taskRepository.createFile(
                with: "Фото размером \(nsImageData.count) kb",
                ext: "jpg",
                size: nsImageData.count,
                taskId: taskId
            )

            self.task = result.0
            tableViewModel.addFileCellVM(result.1)
        } catch {
            // показать ошибку
        }
    }

    private func createTaskFile(from url: URL) {
        do {
            let result = try taskRepository.createFile(
                with: "Файл размером ??? kb",
                ext: url.pathExtension,
                size: 0,
                taskId: taskId
            )

            self.task = result.0
            tableViewModel.addFileCellVM(result.1)
        } catch {
            // показать ошибку
        }
    }

    private func deleteTaskFile(deletableVM: TaskFileDeletableViewModel) {
        guard let indexPath = deletableVM.indexPath else { return }

        let cellVM = tableViewModel.getCellVM(for: indexPath)
        guard let task,
            let fileCellVM = cellVM as? FileCellViewModel,
            case .data(let fileData) = fileCellVM.state,
            let taskFile = task.getFile(by: fileData.id)
        else {
            // показать сообщение об ошибке: (файл не получилось удалить)
            return
        }

        do {
            let task = try taskRepository.deleteFile(taskFile)
            self.task = task

            tableViewModel.deleteFile(with: indexPath)
        } catch {
            // показать сообщение об ошибке: (файл не получилось удалить)
        }
    }

}
// swiftlint:enable type_body_length
