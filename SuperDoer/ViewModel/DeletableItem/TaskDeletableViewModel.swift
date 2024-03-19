
import Foundation

class TaskDeletableViewModel: BaseDeletableItemViewModel {
    
    class override var typeName: ItemTypeName  {
        return ItemTypeName(
            oneIP: "задача",
            oneVP: "задачу",
            manyVP: "задачи"
        )
    }
    
    static func createFrom(task: CDTask, indexPath: IndexPath) -> TaskDeletableViewModel {
        return TaskDeletableViewModel(
            title: task.title ?? "",
            indexPath: indexPath
        )
    }
    
}
