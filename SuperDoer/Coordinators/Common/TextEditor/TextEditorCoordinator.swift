import UIKit
import RxRelay
import RxCocoa
import RxSwift
import Foundation

final class TextEditorCoordinator: BaseCoordinator, TextEditorCoordinatorType {
    private weak var parentController: UIViewController?
    private let data: TextEditorData

    private var viewModel: TextEditorNavigationEmittable?

    private var viewController: UIViewController?
    override var rootViewController: UIViewController? { viewController }

    private let finishResultRelay = PublishRelay<NSAttributedString?>()
    var finishResult: Signal<NSAttributedString?> { finishResultRelay.asSignal() }

    init(
        parent: Coordinator,
        parentVC: UIViewController,
        data: TextEditorData
    ) {
        self.parentController = parentVC
        self.data = data
        super.init(parent: parent)
    }
    
    override func startCoordinator() {
        let vm = TextEditorViewModel(data: data)
        let vc = TextEditorViewController(viewModel: vm)
        viewModel = vm
        viewController = vc

        viewModel?.needSaveAndClose.emit(onNext: { [weak self] result in
            guard let self else { return }
            self.finishResultRelay.accept(result)
            self.viewController?.dismiss(animated: true)
        })
        .disposed(by: disposeBag)

        parentController?.present(vc, animated: true)
    }

}
