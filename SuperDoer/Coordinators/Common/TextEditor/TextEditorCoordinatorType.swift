import RxCocoa
import Foundation

protocol TextEditorCoordinatorType: AnyObject {
    var didCloseEventSignal: Signal<NSAttributedString?> { get }

    func didCloseWithSaveTextEditor(with text: NSAttributedString?)
}
