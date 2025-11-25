import Foundation

final class TaskSectionDeletableViewModel: BaseDeletableItemViewModel {

    override class var typeName: ItemTypeName {
        return ItemTypeName(
            oneIP: "список",
            oneVP: "список",
            manyVP: "списки"
        )
    }
}
