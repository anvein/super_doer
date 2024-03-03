
import Foundation

protocol TextEditorViewModelType {
    var title: String? { get }
    var text: Box<NSMutableAttributedString?> { get }
}
