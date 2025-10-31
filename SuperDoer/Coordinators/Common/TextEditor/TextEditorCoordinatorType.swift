import RxCocoa
import Foundation

protocol TextEditorCoordinatorType: AnyObject {
    var didFinishWithResultSignal: Signal<NSAttributedString?> { get }
}
