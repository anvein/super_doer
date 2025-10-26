import Foundation

protocol DeletableItemViewModelType {
    typealias ItemTypeName = (oneIP: String, oneVP: String, manyVP: String)

    var title: String { get }
    var indexPath: IndexPath? { get }

    static var typeName: ItemTypeName { get }
}
