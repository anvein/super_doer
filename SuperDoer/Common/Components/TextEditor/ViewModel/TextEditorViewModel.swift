import Foundation
import RxRelay
import RxCocoa

class TextEditorViewModel: TextEditorViewModelType {

    private weak var coordinator: TextEditorCoordinatorType?

    // MARK: - State / Rx

    let textRelay = BehaviorRelay<NSAttributedString?>(value: nil)

    private let titleRelay = BehaviorRelay<String?>(value: nil)
    var titleDriver: Driver<String?> {
        titleRelay.asDriver()
    }

    private let subtitleRelay = BehaviorRelay<String?>(value: nil)
    var subtitleDriver: Driver<String?> {
        subtitleRelay.asDriver()
    }

    // MARK: - Init

    init(coordinator: TextEditorCoordinator, data: TextEditorData) {
        self.coordinator = coordinator

        textRelay.accept(data.text)
        titleRelay.accept(data.title)
        subtitleRelay.accept(data.subtitle)
    }

    // MARK: - UI Actions

    func didClose() {
        coordinator?.didCloseWithSaveTextEditor(with: textRelay.value)
    }

}
