
import Foundation

protocol DeletableItem {
    typealias ItemTypeName = (oneIP: String, oneVP: String, manyVP: String)
    
    /// Название, которое должно выводиться при удалении
    var titleForDelete: String { get }
    
    var itemTypeName: ItemTypeName { get }
}
