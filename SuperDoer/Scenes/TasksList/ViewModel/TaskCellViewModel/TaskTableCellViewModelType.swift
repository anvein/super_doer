import Foundation

protocol TaskTableCellViewModelType {
    var isInMyDay: Bool { get }
    var isCompleted: Bool { get }
    var isPriority: Bool { get }
    var title: String { get }

    var attributes: NSAttributedString? { get }

}
