
import Foundation

protocol DeletableItemViewModelType {
    typealias ItemTypeName = (oneIP: String, oneVP: String, manyVP: String)
    
    /// Название, которое должно выводиться при удалении
    var title: String { get }
    
    /// Если элемент является частью таблицы / коллекции, то надо указать IndexPath строки в которой он находится
    var indexPath: IndexPath? { get }
    
    static var typeName: ItemTypeName { get }
}
