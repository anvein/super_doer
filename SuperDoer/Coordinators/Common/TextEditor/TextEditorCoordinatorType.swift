import Foundation
import RxCocoa

protocol TextEditorCoordinatorType: AnyObject {
    var finishResult: Signal<NSAttributedString?> { get }
}
