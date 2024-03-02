
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
            updateObservablePropertiesFrom(task: task)
        }
    }
    
    /// Объект-массив на основании которого формируется таблица с "кнопками" и данными задачи
    /// Прослойка между сущностью Task и данных для вывода задачи в виде таблицы
    private var taskDataViewModels: Box<TaskDataCellViewModels>
    
    var countTaskDataCellsValues: Int {
        return taskDataViewModels.value.viewModels.count
    }
    
    var taskTitle: Box<String?>
    var taskIsCompleted: Box<Bool>
    var taskIsPriority: Box<Bool>
    
    
    init(task: Task) {
        self.task = task
        
        taskTitle = Box(task.title)
        taskIsCompleted = Box(task.isCompleted)
        taskIsPriority = Box(task.isPriority)
        
        taskDataViewModels = Box(TaskDataCellViewModels(task))
    }
    
    
    // MARK: children view models building
    func getTaskDataCellValueFor(indexPath: IndexPath) -> TaskDataCellViewModelType {
        return taskDataViewModels.value.viewModels[indexPath.row]
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
        let fileCellVM = taskDataViewModels.value.viewModels[indexPath.row]
        guard let fileCellVM = fileCellVM as? FileCellViewModel else { return nil }
        
        return fileCellVM
    }
    
    func isFileCellViewModel(byIndexPath indexPath: IndexPath) -> Bool {
        return taskDataViewModels.value.viewModels[indexPath.row] is FileCellViewModel
    }
    
    func getTaskDescriptionEditorViewModel() -> TaskDescriptionEditorViewModel {
        return TaskDescriptionEditorViewModel(task: task)
    }
    
    
    // MARK: model manipulations
    func updateTaskField(title: String) {
        taskEm.updateField(title: title, task: task)
        
        updateObservablePropertiesFrom(task: task)
    }

    func updateTaskField(inMyDay: Bool) {
        taskEm.updateField(inMyDay: inMyDay, task: task)
        
        taskDataViewModels.value.fillAddToMyDay(from: task)
    }
    
    func updateTaskField(deadlineDate: Date?) {
        taskEm.updateField(deadlineDate: deadlineDate, task: task)
        taskDataViewModels.value.fillDeadlineAt(from: task)
    }
    
    func updateTaskField(reminderDateTime: Date?) {
        taskEm.updateField(reminderDateTime: reminderDateTime, task: task)
        taskDataViewModels.value.fillReminderDateTime(from: task)
    }
    
    func updateTaskField(repeatPeriod: String?) {
        taskEm.updateField(repeatPeriod: repeatPeriod, task: task)
        taskDataViewModels.value.fillRepeatPeriod(from: task)
    }
    
    func switchValueTaskFieldInMyDay() {
        let newValue = !task.inMyDay
        updateTaskField(inMyDay: newValue)
    }
    
    func updateTaskField(taskDescription: NSAttributedString?) {
        // TODO: конвертировать из NSAttributedString в хранимый string
        taskEm.updateFields(
            taskDescription: taskDescription?.string,
            descriptionUpdatedAt: Date(),
            task: task
        )
        taskDataViewModels.value.fillDescription(from: task)
    }
    
    func createTaskFile(fromImageData imageData: NSData) {
        let taskFile = taskFileEm.createWith(
            fileName: "Фото размером \(imageData.count) kb",
            fileExtension: "jpg",
            fileSize: imageData.count,
            task: task
        )
        
        taskDataViewModels.value.appendFile(taskFile)
    }
    
    func createTaskFile(fromUrl url: URL) {
        let taskFile = taskFileEm.createWith(
            fileName: "Файл размером ??? kb",
            fileExtension: url.pathExtension,
            fileSize: 0,
            task: task
        )
        
        taskDataViewModels.value.appendFile(taskFile)
    }
    
    func deleteTaskFile(fileCellIndexPath indexPath: IndexPath) {
        let cellValue = taskDataViewModels.value.viewModels[indexPath.row]
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
        
        taskDataViewModels.value.viewModels.remove(at: indexPath.row)
    }
    
    // MARK: binding methods
    func setupBindingTaskDataCellsValues(listener: @escaping (TaskDataCellViewModels) -> ()) {
        taskDataViewModels.bindAndUpdateValue(listener: listener)
    }
    
    private func updateObservablePropertiesFrom(task: Task) {
        if task.title != taskTitle.value {
            taskTitle.value = task.title
        }
        
        if task.isCompleted != taskIsCompleted.value {
            taskIsCompleted.value = task.isCompleted
        }
        
        if task.isPriority != taskIsPriority.value {
            taskIsPriority.value = task.isPriority
        }
        
        taskDataViewModels.value.fill(from: task)
    }
    
}
