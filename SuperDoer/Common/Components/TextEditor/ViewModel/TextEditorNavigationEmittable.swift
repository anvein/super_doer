import RxCocoa
import Foundation

protocol TextEditorNavigationEmittable {
    var didCloseWithSave: Signal<NSAttributedString?> { get }
}
