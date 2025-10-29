import UIKit
import RxRelay
import RxCocoa
import RxSwift
import Foundation

class TextEditorCoordinator: BaseCoordinator {
    let externalDiposeBag = DisposeBag()

    private weak var parentVC: UIViewController?
    private let data: TextEditorData

    private let didCloseAndSaveEventRelay = PublishRelay<NSAttributedString?>()

    init(
        parent: Coordinator,
        parentVC: UIViewController,
        data: TextEditorData
    ) {
        self.parentVC = parentVC
        self.data = data
        super.init(parent: parent)
    }
    
    override func start() {
        let vm = TextEditorViewModel(coordinator: self, data: data)
        let vc = TextEditorViewController(viewModel: vm)
        
        parentVC?.present(vc, animated: true)
    }

}

// MARK: - TextEditorCoordinatorType

extension TextEditorCoordinator: TextEditorCoordinatorType {
    var didCloseEventSignal: Signal<NSAttributedString?> {
        didCloseAndSaveEventRelay.asSignal()
    }

    func didCloseWithSaveTextEditor(with text: NSAttributedString?) {
        didCloseAndSaveEventRelay.accept(text)
        finish()
    }

}
