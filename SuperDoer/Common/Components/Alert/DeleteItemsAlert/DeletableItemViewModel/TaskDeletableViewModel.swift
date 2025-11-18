import Foundation

class TaskDeletableViewModel: BaseDeletableItemViewModel {

    override class var typeName: ItemTypeName {
        return ItemTypeName(
            oneIP: "задача",
            oneVP: "задачу",
            manyVP: "задачи"
        )
    }

    init(task: TasksListItemEntity, indexPath: IndexPath) {
        super.init(
            title: task.title,
            indexPath: indexPath
        )
    }

}
