import RxCocoa
import Foundation

protocol TextEditorCoordinatorType: AnyObject {
    var finishResult: Signal<NSAttributedString?> { get }
}
