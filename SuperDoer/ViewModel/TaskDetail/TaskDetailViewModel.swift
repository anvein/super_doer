
import Foundation

/// ViewModel страницы открытой задачи (просмотр / редактирование)
class TaskDetailViewModel {
    
    lazy var taskEm = TaskEntityManager()
    
    // TODO: сделать private всё
    // инициализировать наблюдаемые поля при инициализации сущности
    private(set) var task: Task {
        didSet {
            updateObservablePropertiesFrom(task: task)
        }
    }
    
    /// Объект-массив на основании которого формируется таблица с "кнопками" и данными задачи
    /// Прослойка между сущностью Task и данных для вывода задачи в виде таблицы
    private var taskDataCellsValues: Box<TaskDataCellValues>
    
    var countTaskDataCellsValues: Int {
        return taskDataCellsValues.value.cellsValuesArray.count
    }
    
    var taskTitle: Box<String?>
    var taskIsCompleted: Box<Bool>
    var taskIsPriority: Box<Bool>
    
    
    init(task: Task) {
        self.task = task
        
        taskTitle = Box(task.title)
        taskIsCompleted = Box(task.isCompleted)
        taskIsPriority = Box(task.isPriority)
        
        taskDataCellsValues = Box(TaskDataCellValues(task))
    }
    
    
    // MARK: children view models building
    func getTaskDataCellValueFor(indexPath: IndexPath) -> TaskDataCellValueProtocol {
        return taskDataCellsValues.value.cellsValuesArray[indexPath.row]
    }
    
    func getTaskDeadlineTableVariantsViewModel() -> TaskDeadlineTableVariantsViewModel {
        return TaskDeadlineTableVariantsViewModel(task: task)
    }
    
    func getTaskReminderCustomDateViewModel() -> TaskReminderCustomDateViewModel {
        return TaskReminderCustomDateViewModel(task: task)
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
        
        taskDataCellsValues.value.fillAddToMyDay(from: task)
    }
    
    func updateTaskField(deadlineDate: Date?) {
        taskEm.updateField(deadlineDate: deadlineDate, task: task)
        taskDataCellsValues.value.fillDeadlineAt(from: task)
    }
    
    func updateTaskField(reminderDateTime: Date?) {
        taskEm.updateField(reminderDateTime: reminderDateTime, task: task)
        taskDataCellsValues.value.fillReminderDateTime(from: task)
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
        taskDataCellsValues.value.fillDescription(from: task)
    }
    
    
    // MARK: binding methods
    func setupBindingTaskDataCellsValues(listener: @escaping (TaskDataCellValues) -> ()) {
        taskDataCellsValues.bindAndUpdateValue(listener: listener)
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
        
        taskDataCellsValues.value.fill(from: task)
    }
    
}
