import Foundation
import RxCocoa
import RxRelay

protocol TextEditorViewModelType {
    var textRelay: BehaviorRelay<NSAttributedString?> { get }
    var titleDriver: Driver<String?> { get }
    var subtitleDriver: Driver<String?> { get }

    func didClose()
}
