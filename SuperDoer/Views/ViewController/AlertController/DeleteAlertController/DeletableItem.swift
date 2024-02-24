
import Foundation

protocol DeletableItem {
    /// Название, которое должно выводиться при удалении
    var title: String { get }
    
    var itemTypeName: (one: String, many: String) { get }
}
