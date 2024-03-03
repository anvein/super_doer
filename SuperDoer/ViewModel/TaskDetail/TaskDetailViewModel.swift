
import Foundation

/// ViewModel страницы открытой задачи (просмотр / редактирование)
class TaskDetailViewModel {
    
    // TODO: переделать на DI
    lazy var taskEm = TaskEntityManager()
    lazy var taskFileEm = TaskFileEntityManager()
    
    // TODO: сделать private всё
    // инициализировать наблюдаемые поля при инициализации сущности
    private(set) var task: Task {
        didSet {
            updateSimpleObservablePropertiesFrom(task)
            taskDataViewModels.fill(from: task)
        }
    }
    
    /// Объект-массив на основании которого формируется таблица с "кнопками" и данными задачи
    /// Прослойка между сущностью Task и данных для вывода задачи в виде таблицы
    private var taskDataViewModels: TaskDataCellViewModels
    
    var countTaskDataCellsValues: Int {
        return taskDataViewModels.viewModels.count
    }
    
    var taskTitle: Box<String?>
    var taskIsCompleted: Box<Bool>
    var taskIsPriority: Box<Bool>
    
    weak var bindingDelegate: TaskDetailViewModelBindingDelegate?
    
    init(task: Task) {
        self.task = task
        
        taskTitle = Box(task.title)
        taskIsCompleted = Box(task.isCompleted)
        taskIsPriority = Box(task.isPriority)
        
        taskDataViewModels = TaskDataCellViewModels(task)
    }
    
    
    // MARK: children view models building
    func getTaskDataCellViewModelFor(indexPath: IndexPath) -> TaskDataCellViewModelType {
        return taskDataViewModels.viewModels[indexPath.row]
    }
    
    func getTaskDeadlineTableVariantsViewModel() -> TaskDeadlineTableVariantsViewModel {
        return TaskDeadlineTableVariantsViewModel(task: task)
    }
    
    func getTaskDeadlineCustomDateSetterViewModel() -> TaskDeadlineCustomDateViewModel {
        return TaskDeadlineCustomDateViewModel(task: task)
    }
    
    func getTaskReminderCustomDateViewModel() -> TaskReminderCustomDateViewModel {
        return TaskReminderCustomDateViewModel(task: task)
    }
    
    func getTaskRepeatPeriodTableVariantsViewModel() -> TaskRepeatPeriodTableVariantsViewModel {
        return TaskRepeatPeriodTableVariantsViewModel(task: task)
    }
    
    func getCustomTaskRepeatPeriodSetterViewModel() -> CustomTaskRepeatPeriodSetterViewModel {
        return CustomTaskRepeatPeriodSetterViewModel(task: task)
    }
    
    func getFileCellViewModel(forIndexPath indexPath: IndexPath) -> FileCellViewModel? {
        let fileCellVM = taskDataViewModels.viewModels[indexPath.row]
        guard let fileCellVM = fileCellVM as? FileCellViewModel else { return nil }
        
        return fileCellVM
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
    
    func updateTaskField(taskDescription: NSAttributedString?) {
        // TODO: конвертировать из NSAttributedString в хранимый string
        taskEm.updateFields(
            taskDescription: taskDescription?.string,
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
    
    func deleteTaskFile(fileCellIndexPath indexPath: IndexPath) {
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
    private func updateSimpleObservablePropertiesFrom(_ task: Task) {
        if task.title != taskTitle.value {
            taskTitle.value = task.title
        }
        
        if task.isCompleted != taskIsCompleted.value {
            taskIsCompleted.value = task.isCompleted
        }
        
        if task.isPriority != taskIsPriority.value {
            taskIsPriority.value = task.isPriority
        }
    }
    
    private func updateBindedCell(
        withRowIndex rowIndex: TaskDataCellViewModels.RowIndex
    ) {
        let indexPath =  IndexPath(row: rowIndex, section: 0)

        bindingDelegate?.updateCell(
            withIndexPath: indexPath,
            cellViewModel: getTaskDataCellViewModelFor(indexPath: indexPath)
        )
    }
    
    private func addBindedCell(
        withRowIndex rowIndex: TaskDataCellViewModels.RowIndex
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

