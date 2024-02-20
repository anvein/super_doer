
import Foundation

/// ViewModel страницы открытой задачи (просмотр / редактирование)
class TaskViewModel {
    
    lazy var taskEm = TaskEntityManager()
    
    // TODO: сделать private всё
    private(set) var task: Task {
        didSet {
            taskTitle.value = task.title
            taskIsCompleted.value = task.isCompleted
            taskIsPriority.value = task.isPriority
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
    
    
    func updateTaskField(title: String) {
        taskEm.updateField(title: title + "+", task: task)
        // так делать?
        // или написать общий метод, который будет обновлять все поля???
        // как правильно???
        // TODO: проблема в том, что task обновился (его поле), а поле vm (которое Box) не обновляется - как его обновить?
        taskTitle.value = title
    }
    
    func getTaskDataCellValueFor(indexPath: IndexPath) -> TaskDataCellValueProtocol {
        return taskDataCellsValues.cellsValuesArray[indexPath.row]
    }
    
}
