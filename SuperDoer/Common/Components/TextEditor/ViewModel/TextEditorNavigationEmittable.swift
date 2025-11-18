import Foundation
import RxCocoa

protocol TextEditorNavigationEmittable {
    var needSaveAndClose: Signal<NSAttributedString?> { get }
}
