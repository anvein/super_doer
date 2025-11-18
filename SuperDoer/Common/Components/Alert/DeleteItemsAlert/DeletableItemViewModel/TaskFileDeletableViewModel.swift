import Foundation

class TaskFileDeletableViewModel: BaseDeletableItemViewModel {

    override class var typeName: ItemTypeName {
        return ItemTypeName(
            oneIP: "файл",
            oneVP: "файл",
            manyVP: "файлы"
        )
    }
}
