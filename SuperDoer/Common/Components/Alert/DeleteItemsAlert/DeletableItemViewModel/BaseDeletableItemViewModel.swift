import Foundation

class BaseDeletableItemViewModel: DeletableItemViewModelType {
    var title: String
    var indexPath: IndexPath?

    class var typeName: ItemTypeName {
        return ItemTypeName(
            oneIP: "элемент",
            oneVP: "элемент",
            manyVP: "элементы"
        )
    }

    init(title: String, indexPath: IndexPath? = nil) {
        self.title = title
        self.indexPath = indexPath
    }
}
