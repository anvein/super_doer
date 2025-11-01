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
    /// Объект с массивом CellVM's на основании которого формируется таблица с "кнопками" и данными задачи
    /// Прослойка между сущностью CDTask и таблицей с данными задачи
    private var tableViewModel: TaskDetailTableViewModel = .init()

    private let titleRelay = BehaviorRelay<String>(value: "")
    private let isCompletedRelay = BehaviorRelay<Bool>(value: false)
    private let isPriorityRelay = BehaviorRelay<Bool>(value: false)
    private let fieldEditingStateRelay = BehaviorRelay<TaskDetailViewModelFieldEditingState?>(value: nil)
    private let tableUpdateRelay = PublishRelay<TaskDetailTableUpdateEvent>()

    // MARK: - Input

    let inputEvent = PublishRelay<TaskDetailViewModelInputEvent>()

    // MARK: - Output (properties)

    var titleDriver: Driver<String> { titleRelay.asDriver() }
    var isCompletedDriver: Driver<Bool> { isCompletedRelay.asDriver() }
    var isPriorityDriver: Driver<Bool> { isPriorityRelay.asDriver() }
    var fieldEditingStateDriver: Driver<TaskDetailViewModelFieldEditingState?> {
        fieldEditingStateRelay.distinctUntilChanged().asDriver(onErrorJustReturn: nil)
    }
    var tableUpdateSignal: Signal<TaskDetailTableUpdateEvent> { tableUpdateRelay.asSignal() }
    var countSections: Int { tableViewModel.countSections }
    var isEnableNotifications: Bool {
        // TODO: получить из сервиса, который вернет "включены ли уведомления"
        return true
    }

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

    func getTableCellViewModel(for indexPath: IndexPath) -> TaskDetailDataCellViewModelType? {
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
        }
    }

    private func handleInputEvent(_ event: TaskDetailViewModelInputEvent) {
        switch event {
        case .needLoadInitialData:
            loadInitialData()

        case .didTapOpenDeadlineDateSetter:
            guard let task else { return }
            navigationEventRelay.accept(
                .openDeadlineDateSetter(deadlineAt: task.deadlineDate)
            )

        case .didTapOpenReminderDateSetter:
            navigationEventRelay.accept(.openReminderDateSetter)

        case .didTapOpenRepeatPeriodSetter:
            navigationEventRelay.accept(.openRepeatPeriodSetter)

        case .didTapAddFile:
            navigationEventRelay.accept(.openAddFile)

        case .didTapFileDelete(indexPath: let indexPath):
//            navigationEventRelay.accept(.openDeleteFileConfirmation(viewModel: <#T##TaskFileDeletableViewModel#>))
            break

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
            text: task.descriptionTextAttributed,
            title: task.title
        )
        navigationEventRelay.accept(
            .openDescriptionEditor(editorData)
        )
    }

    // MARK: - Children view models building
    

//    func getTaskDeadlineTableVariantsViewModel() -> TaskDeadlineTableVariantsViewModel {
//        return TaskDeadlineTableVariantsViewModel(deadlineDate: task.deadlineDate)
//    }
//    
//    func getTaskReminderCustomDateViewModel() -> TaskReminderCustomDateViewModel {
//        return TaskReminderCustomDateViewModel(task: task)
//    }
//    
//    func getTaskRepeatPeriodTableVariantsViewModel() -> TaskRepeatPeriodTableVariantsViewModel {
//        return TaskRepeatPeriodTableVariantsViewModel(repeatPeriod: task.repeatPeriod)
//    }
//    
//    func getFileCellViewModel(for indexPath: IndexPath) -> FileCellViewModel? {
//        let fileCellVM = taskDataViewModels.getCellVM(for: indexPath)
//        guard let fileCellVM = fileCellVM as? FileCellViewModel else { return nil }
//        
//        return fileCellVM
//    }
//    
//    func getFileDeletableViewModel(for indexPath: IndexPath) -> TaskFileDeletableViewModel? {
//        guard let fileCellVM = getFileCellViewModel(for: indexPath) else { return nil }
//
//        return TaskFileDeletableViewModel.createFrom(
//            fileCellViewModel: fileCellVM,
//            indexPath: indexPath
//        )
//    }

    // MARK: - Fetching Data

    private func loadInitialData() {
        guard let task = taskEm.getTaskBy(id: taskId) else { return }

        self.task = task
        titleRelay.accept(task.titlePrepared)
        isCompletedRelay.accept(task.isCompleted)
        isPriorityRelay.accept(task.isPriority)

        tableViewModel = TaskDetailTableViewModel(task)
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
        
        guard let indexPath = tableViewModel.fillAddToMyDay(from: task) else { return }
        updateBindedCell(with: indexPath)
    }
    
    private func toggleValueTaskFieldInMyDay() {
        guard let task else { return }
        let newValue = !task.inMyDay
        updateTaskField(inMyDay: newValue)
    }
    
    private func updateTaskField(deadlineDate: Date?) {
        guard let task else { return }
        taskEm.updateField(deadlineDate: deadlineDate, task: task)

        guard let indexPath = tableViewModel.fillDeadlineAt(from: task) else { return }
        updateBindedCell(with: indexPath)
    }
    
    private func updateTaskField(reminderDateTime: Date?) {
        guard let task else { return }
        taskEm.updateField(reminderDateTime: reminderDateTime, task: task)

        guard let indexPath = tableViewModel.fillReminderDate(from: task) else { return }
        updateBindedCell(with: indexPath)
    }
    
    private func updateTaskField(repeatPeriod: String?) {
        guard let task else { return }
        taskEm.updateField(repeatPeriod: repeatPeriod, task: task)

        guard let indexPath = tableViewModel.fillRepeatPeriod(from: task) else { return }
        updateBindedCell(with: indexPath)
    }
    
    private func updateTaskField(descriptionText: NSAttributedString?) {
        guard let task else { return }
        // TODO: конвертировать из NSAttributedString в хранимый string
        taskEm.updateFields(
            descriptionText: descriptionText,
            descriptionUpdatedAt: Date(),
            task: task
        )

        guard let indexPath = tableViewModel.fillDescription(from: task) else { return }
        updateBindedCell(with: indexPath)
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
        
        guard let indexPath = tableViewModel.addFile(taskFile) else { return }
        addBindedCell(with: indexPath)
    }
    
    private func createTaskFile(from url: URL) {
        guard let task else { return }

        let taskFile = taskFileEm.createWith(
            fileName: "Файл размером ??? kb",
            fileExtension: url.pathExtension,
            fileSize: 0,
            task: task
        )
        
        guard let indexPath = tableViewModel.addFile(taskFile) else { return }
        addBindedCell(with: indexPath)
    }
    
    private func deleteTaskFile(fileDeletableVM: TaskFileDeletableViewModel) {
        guard let task else { return }

        guard let indexPath = fileDeletableVM.indexPath else { return }

        let cellValue = tableViewModel.getCellVM(for: indexPath)
        guard let fileCellValue = cellValue as? FileCellViewModel else {
            // TODO: показать сообщение об ошибке (файл не получилось удалить)
            return
        }
        
        let taskFile = task.getFileBy(id: fileCellValue.id)
        guard let taskFile else  {
            // TODO: показать сообщение об ошибке (файл не получилось удалить)
            return
        }
        
        taskFileEm.delete(file: taskFile)
        tableViewModel.deleteFile(with: indexPath)

        tableUpdateRelay.accept(
            .removeCells(with: [indexPath])
        )
    }

    // MARK: Binding methods

//    private func updateSimpleObservablePropertiesFrom(_ task: CDTask) {
//        if task.title != titleRelay.value {
//            titleRelay.accept(task.titlePrepared)
//        }
//        
//        if task.isCompleted != isCompletedRelay.value {
//            isCompletedRelay.accept(task.isCompleted)
//        }
//        
//        if task.isPriority != isPriorityRelay.value {
//            isPriorityRelay.accept(task.isPriority)
//        }
//    }
    
    private func updateBindedCell(with indexPath: IndexPath) {
        guard let cellVM = getTableCellViewModel(for: indexPath) else { return }

        tableUpdateRelay.accept(
            .updateCell(with: indexPath, cellVM: cellVM)
        )
    }
    
    private func addBindedCell(with indexPath: IndexPath) {
        guard let cellVM = getTableCellViewModel(for: indexPath) else { return }

        tableUpdateRelay.accept(
            .addCell(to: indexPath, cellVM: cellVM)
        )
    }
}
