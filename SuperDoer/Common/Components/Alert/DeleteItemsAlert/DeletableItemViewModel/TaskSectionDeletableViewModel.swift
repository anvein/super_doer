import Foundation

class TaskSectionDeletableViewModel: BaseDeletableItemViewModel {

    class override var typeName: ItemTypeName {
        return ItemTypeName(
            oneIP: "список",
            oneVP: "список",
            manyVP: "списки"
        )
    }
}
