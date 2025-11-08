import RxCocoa
import Foundation

protocol TextEditorNavigationEmittable {
    var needSaveAndClose: Signal<NSAttributedString?> { get }
}
