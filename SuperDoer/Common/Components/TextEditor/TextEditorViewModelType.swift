
import Foundation

protocol TextEditorViewModelType {
    var title: String? { get }
    var textObservable: UIBoxObservable<NSMutableAttributedString?> { get }
}
