import Foundation

class TaskFileDeletableViewModel: BaseDeletableItemViewModel {

    class override var typeName: ItemTypeName {
        return ItemTypeName(
            oneIP: "файл",
            oneVP: "файл",
            manyVP: "файлы"
        )
    }
}
