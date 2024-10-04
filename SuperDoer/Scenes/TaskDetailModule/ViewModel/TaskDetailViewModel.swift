
import Foundation
import RxCocoa
import RxRelay

final class TaskDetailViewModel {

    // TODO: - Services

    private let taskEm: TaskCoreDataManager
    private let taskFileEm: TaskFileEntityManager

    weak var bindingDelegate: TaskDetailViewModelBindingDelegate?

    // MARK: - Model

    private var task: CDTask {
        didSet {
            updateSimpleObservablePropertiesFrom(task)
            taskDataViewModels.fill(from: task)
        }
    }

    // MARK: - State
    /// Объект-массив на основании которого формируется таблица с "кнопками" и данными задачи
    /// Прослойка между сущностью Task и данных для вывода задачи в виде таблицы
    private var taskDataViewModels: TaskDetailDataCellViewModels

    var countSections: Int { taskDataViewModels.countSections }

    private let titleRelay = BehaviorRelay<String>(value: "")
    private let isCompletedRelay = BehaviorRelay<Bool>(value: false)
    private let isPriorityRelay = BehaviorRelay<Bool>(value: false)

    private let fieldEditingStateRelay = BehaviorRelay<FieldEditingState?>(value: nil)

    var isEnableNotifications: Bool {
        // TODO: получить из сервиса, который вернет "включены ли уведомления"
        return true
    }

    // MARK: - Observable

    var titleDriver: Driver<String> { titleRelay.asDriver() }
    var isCompletedDriver: Driver<Bool> { isCompletedRelay.asDriver() }
    var isPriorityDriver: Driver<Bool> { isPriorityRelay.asDriver()}

    var fieldEditingStateDriver: Signal<FieldEditingState?> { fieldEditingStateRelay.asSignal(onErrorJustReturn: nil) }

    // MARK: - Init

    init(
        _ taskId: UUID,
        taskEm: TaskCoreDataManager,
        taskFileEm: TaskFileEntityManager
    ) {
        self.taskEm = taskEm
        self.taskFileEm = taskFileEm

        task = taskEm.getTaskBy(id: taskId)! // TODO: переделать это

        titleRelay.accept(task.titlePrepared)
        isCompletedRelay.accept(task.isCompleted)
        isPriorityRelay.accept(task.isPriority)
//
        taskDataViewModels = TaskDetailDataCellViewModels(task)
    }

    // MARK: - Table getters

    func getCountRowsInSection(_ sectionIndex: Int) -> Int {
        return taskDataViewModels.getCountRowsInSection(sectionIndex)
    }

    func isFileCellViewModel(with indexPath: IndexPath) -> Bool {
        return taskDataViewModels.getCellVM(for: indexPath) is FileCellViewModel
    }

    // MARK: - Children view models building

    func getTaskDataCellViewModelFor(indexPath: IndexPath) -> TaskDetailDataCellViewModelType? {
        return taskDataViewModels.getCellVM(for: indexPath)
    }

    func getTaskDeadlineTableVariantsViewModel() -> TaskDeadlineTableVariantsViewModel {
        return TaskDeadlineTableVariantsViewModel(deadlineDate: task.deadlineDate)
    }
    
    func getTaskReminderCustomDateViewModel() -> TaskReminderCustomDateViewModel {
        return TaskReminderCustomDateViewModel(task: task)
    }
    
    func getTaskRepeatPeriodTableVariantsViewModel() -> TaskRepeatPeriodTableVariantsViewModel {
        return TaskRepeatPeriodTableVariantsViewModel(repeatPeriod: task.repeatPeriod)
    }
    
    func getFileCellViewModel(for indexPath: IndexPath) -> FileCellViewModel? {
        let fileCellVM = taskDataViewModels.getCellVM(for: indexPath)
        guard let fileCellVM = fileCellVM as? FileCellViewModel else { return nil }
        
        return fileCellVM
    }
    
    func getFileDeletableViewModel(for indexPath: IndexPath) -> TaskFileDeletableViewModel? {
        guard let fileCellVM = getFileCellViewModel(for: indexPath) else { return nil }

        return TaskFileDeletableViewModel.createFrom(
            fileCellViewModel: fileCellVM,
            indexPath: indexPath
        )
    }
    
    func getTaskDescriptionEditorViewModel() -> TaskDescriptionEditorViewModel {
        return TaskDescriptionEditorViewModel(task: task)
    }

    // MARK: - Model manipulations

    func updateTaskField(title: String) {
        taskEm.updateField(title: title, task: task)
        updateSimpleObservablePropertiesFrom(task)
    }
    
    func updateTaskField(isCompleted: Bool) {
        taskEm.updateField(isCompleted: isCompleted, task: task)
        updateSimpleObservablePropertiesFrom(task)
    }
    
    func updateTaskField(isPriority: Bool) {
        taskEm.updateField(isPriority: isPriority, task: task)
        updateSimpleObservablePropertiesFrom(task)
    }

    func updateTaskField(inMyDay: Bool) {
        taskEm.updateField(inMyDay: inMyDay, task: task)
        
        guard let indexPath = taskDataViewModels.fillAddToMyDay(from: task) else { return }
        updateBindedCell(with: indexPath)
    }
    
    func switchValueTaskFieldInMyDay() {
        let newValue = !task.inMyDay
        updateTaskField(inMyDay: newValue)
    }
    
    func updateTaskField(deadlineDate: Date?) {
        taskEm.updateField(deadlineDate: deadlineDate, task: task)

        guard let indexPath = taskDataViewModels.fillDeadlineAt(from: task) else { return }
        updateBindedCell(with: indexPath)
    }
    
    func updateTaskField(reminderDateTime: Date?) {
        taskEm.updateField(reminderDateTime: reminderDateTime, task: task)

        guard let indexPath = taskDataViewModels.fillReminderDate(from: task) else { return }
        updateBindedCell(with: indexPath)
    }
    
    func updateTaskField(repeatPeriod: String?) {
        taskEm.updateField(repeatPeriod: repeatPeriod, task: task)

        guard let indexPath = taskDataViewModels.fillRepeatPeriod(from: task) else { return }
        updateBindedCell(with: indexPath)
    }
    
    func updateTaskField(descriptionText: NSAttributedString?) {
        // TODO: конвертировать из NSAttributedString в хранимый string
        taskEm.updateFields(
            descriptionText: descriptionText?.string,
            descriptionUpdatedAt: Date(),
            task: task
        )

        guard let indexPath = taskDataViewModels.fillDescription(from: task) else { return }
        updateBindedCell(with: indexPath)
    }
    
    func createTaskFile(fromImageData imageData: NSData) {
        let taskFile = taskFileEm.createWith(
            fileName: "Фото размером \(imageData.count) kb",
            fileExtension: "jpg",
            fileSize: imageData.count,
            task: task
        )
        
        guard let indexPath = taskDataViewModels.addFile(taskFile) else { return }
        addBindedCell(with: indexPath)
    }
    
    func createTaskFile(fromUrl url: URL) {
        let taskFile = taskFileEm.createWith(
            fileName: "Файл размером ??? kb",
            fileExtension: url.pathExtension,
            fileSize: 0,
            task: task
        )
        
        guard let indexPath = taskDataViewModels.addFile(taskFile) else { return }
        addBindedCell(with: indexPath)
    }
    
    func deleteTaskFile(fileDeletableVM: TaskFileDeletableViewModel) {
        guard let indexPath = fileDeletableVM.indexPath else {
            // TODO: залогировать
            return
        }
        
        let cellValue = taskDataViewModels.getCellVM(for: indexPath)
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
        taskDataViewModels.deleteFile(with: indexPath)

        bindingDelegate?.removeCells(withIndexPaths: [indexPath])
    }

    // MARK: - State manipulation

    func setEditingState(_ state: FieldEditingState?) {
        guard fieldEditingStateRelay.value != state else { return }
        fieldEditingStateRelay.accept(state)
    }

    // MARK: Binding methods

    private func updateSimpleObservablePropertiesFrom(_ task: CDTask) {
        if task.title != titleRelay.value {
            titleRelay.accept(task.titlePrepared)
        }
        
        if task.isCompleted != isCompletedRelay.value {
            isCompletedRelay.accept(task.isCompleted)
        }
        
        if task.isPriority != isPriorityRelay.value {
            isPriorityRelay.accept(task.isPriority)
        }
    }
    
    private func updateBindedCell(with indexPath: IndexPath) {
        guard let cellVM = getTaskDataCellViewModelFor(indexPath: indexPath) else { return }
        bindingDelegate?.updateCell(
            withIndexPath: indexPath,
            cellViewModel: cellVM
        )
    }
    
    private func addBindedCell(with indexPath: IndexPath) {
        guard let cellVM = getTaskDataCellViewModelFor(indexPath: indexPath) else { return }
        bindingDelegate?.addCell(
            toIndexPath: indexPath,
            cellViewModel: cellVM
        )
    }
}

// MARK: - TaskDetailViewModel.EditState

extension TaskDetailViewModel {
    enum FieldEditingState: Equatable {
        case taskTitleEditing
        case subtaskAdding
        case subtastEditing(indexPath: IndexPath)
    }
}
