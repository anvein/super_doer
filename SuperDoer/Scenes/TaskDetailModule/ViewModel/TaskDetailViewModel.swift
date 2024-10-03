
import Foundation
import RxCocoa
import RxRelay

class TaskDetailViewModel {

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
    
    var countTaskDataCells: Int {  taskDataViewModels.viewModels.count }

    private let titleRelay = BehaviorRelay<String>(value: "")
    private let isCompletedRelay = BehaviorRelay<Bool>(value: false)
    private let isPriorityRelay = BehaviorRelay<Bool>(value: false)

    var isEnableNotifications: Bool {
        // TODO: получить из сервиса, который вернет "включены ли уведомления"
        return true
    }

    // MARK: - Observable

    var titleDriver: Driver<String> { titleRelay.asDriver() }
    var isCompletedDriver: Driver<Bool> { isCompletedRelay.asDriver() }
    var isPriorityDriver: Driver<Bool> { isPriorityRelay.asDriver()}

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
    
    
    // MARK: children view models building
    func getTaskDataCellViewModelFor(indexPath: IndexPath) -> TaskDataCellViewModelType {
        return taskDataViewModels.viewModels[indexPath.row]
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
    
    func getFileCellViewModel(forIndexPath indexPath: IndexPath) -> FileCellViewModel? {
        let fileCellVM = taskDataViewModels.viewModels[indexPath.row]
        guard let fileCellVM = fileCellVM as? FileCellViewModel else { return nil }
        
        return fileCellVM
    }
    
    func getFileDeletableViewModelFor(_ indexPath: IndexPath) -> TaskFileDeletableViewModel? {
        let fileCellVM = taskDataViewModels.viewModels[indexPath.row]
        guard let fileCellVM = fileCellVM as? FileCellViewModel else { return nil }
        
        return TaskFileDeletableViewModel.createFrom(
            fileCellViewModel: fileCellVM,
            indexPath: indexPath
        )
    }
    
    func isFileCellViewModel(byIndexPath indexPath: IndexPath) -> Bool {
        return taskDataViewModels.viewModels[indexPath.row] is FileCellViewModel
    }
    
    func getTaskDescriptionEditorViewModel() -> TaskDescriptionEditorViewModel {
        return TaskDescriptionEditorViewModel(task: task)
    }
    
    
    // MARK: model manipulations
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
        
        let rowIndex = taskDataViewModels.fillAddToMyDay(from: task)
        
        guard let rowIndex else { return }
        updateBindedCell(withRowIndex: rowIndex)
    }
    
    func switchValueTaskFieldInMyDay() {
        let newValue = !task.inMyDay
        updateTaskField(inMyDay: newValue)
    }
    
    func updateTaskField(deadlineDate: Date?) {
        taskEm.updateField(deadlineDate: deadlineDate, task: task)
        
        let rowIndex = taskDataViewModels.fillDeadlineAt(from: task)
        
        guard let rowIndex else { return }
        updateBindedCell(withRowIndex: rowIndex)
    }
    
    func updateTaskField(reminderDateTime: Date?) {
        taskEm.updateField(reminderDateTime: reminderDateTime, task: task)
        
        let rowIndex = taskDataViewModels.fillReminderDateTime(from: task)
        
        guard let rowIndex else { return }
        updateBindedCell(withRowIndex: rowIndex)
    }
    
    func updateTaskField(repeatPeriod: String?) {
        taskEm.updateField(repeatPeriod: repeatPeriod, task: task)
        
        let rowIndex = taskDataViewModels.fillRepeatPeriod(from: task)
        
        guard let rowIndex else { return }
        updateBindedCell(withRowIndex: rowIndex)
    }
    
    func updateTaskField(descriptionText: NSAttributedString?) {
        // TODO: конвертировать из NSAttributedString в хранимый string
        taskEm.updateFields(
            descriptionText: descriptionText?.string,
            descriptionUpdatedAt: Date(),
            task: task
        )
        let rowIndex = taskDataViewModels.fillDescription(from: task)
        
        guard let rowIndex else { return }
        updateBindedCell(withRowIndex: rowIndex)
    }
    
    func createTaskFile(fromImageData imageData: NSData) {
        let taskFile = taskFileEm.createWith(
            fileName: "Фото размером \(imageData.count) kb",
            fileExtension: "jpg",
            fileSize: imageData.count,
            task: task
        )
        
        let rowIndex = taskDataViewModels.appendFile(taskFile)
        addBindedCell(withRowIndex: rowIndex)
    }
    
    func createTaskFile(fromUrl url: URL) {
        let taskFile = taskFileEm.createWith(
            fileName: "Файл размером ??? kb",
            fileExtension: url.pathExtension,
            fileSize: 0,
            task: task
        )
        
        let rowIndex = taskDataViewModels.appendFile(taskFile)
        addBindedCell(withRowIndex: rowIndex)
    }
    
    func deleteTaskFile(fileDeletableVM: TaskFileDeletableViewModel) {
        guard let indexPath = fileDeletableVM.indexPath else {
            // TODO: залогировать
            return
        }
        
        let cellValue = taskDataViewModels.viewModels[indexPath.row]
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
        taskDataViewModels.viewModels.remove(at: indexPath.row)
        
        bindingDelegate?.removeCells(withIndexPaths: [indexPath])
    }
    
    
    // MARK: binding methods

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
    
    private func updateBindedCell(
        withRowIndex rowIndex: TaskDetailDataCellViewModels.RowIndex
    ) {
        let indexPath =  IndexPath(row: rowIndex, section: 0)

        bindingDelegate?.updateCell(
            withIndexPath: indexPath,
            cellViewModel: getTaskDataCellViewModelFor(indexPath: indexPath)
        )
    }
    
    private func addBindedCell(
        withRowIndex rowIndex: TaskDetailDataCellViewModels.RowIndex
    ) {
        let indexPath = IndexPath(row: rowIndex, section: 0)
        bindingDelegate?.addCell(
            toIndexPath: indexPath,
            cellViewModel: getTaskDataCellViewModelFor(indexPath: indexPath)
        )
    }
}


// MARK: delegate protocol for update view (binding)
protocol TaskDetailViewModelBindingDelegate: AnyObject {
    func addCell(toIndexPath indexPath: IndexPath, cellViewModel: TaskDataCellViewModelType)
    
    func updateCell(withIndexPath indexPath: IndexPath, cellViewModel: TaskDataCellViewModelType)
    
    func removeCells(withIndexPaths indexPaths: [IndexPath])
}

