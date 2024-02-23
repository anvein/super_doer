
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
    private var taskDataCellsValues = TaskDataCellValues()
    
    var countTaskDataCellsValues: Int {
        return taskDataCellsValues.cellsValuesArray.count
    }
    
    var taskTitle: Box<String?>
    var taskIsCompleted: Box<Bool>
    var taskIsPriority: Box<Bool>
    
    
    init(task: Task) {
        self.task = task
        
        taskTitle = Box(task.title)
        taskIsCompleted = Box(task.isCompleted)
        taskIsPriority = Box(task.isPriority)
        
        taskDataCellsValues.fill(from: task)
    }
    
    
    func getTaskDataCellValueFor(indexPath: IndexPath) -> TaskDataCellValueProtocol {
        return taskDataCellsValues.cellsValuesArray[indexPath.row]
    }
    
    // ViewModel
    func updateTaskField(title: String) {
        let title = title + "+"
        // поле сущности обновилась
        taskEm.updateField(title: title, task: task)
        
        // обновлять наблюдаемые свойства вручную универсальным методом
        updateObservablePropertiesFrom(task: task)
    }

    // сделать метод, который будет обновлять только те наблюдаемые поля,
    // которые обновились
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
    }
    
}
