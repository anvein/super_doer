
import Foundation

class TaskDeletableViewModel: BaseDeletableItemViewModel {
    
    class override var typeName: ItemTypeName  {
        return ItemTypeName(
            oneIP: "задача",
            oneVP: "задачу",
            manyVP: "задачи"
        )
    }
    
    init(task: TaskListItem, indexPath: IndexPath) {
        super.init(
            title: task.title,
            indexPath: indexPath
        )
    }
    
}
