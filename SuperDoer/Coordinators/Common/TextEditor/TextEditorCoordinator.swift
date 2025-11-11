import UIKit
import RxRelay
import RxCocoa
import RxSwift
import Foundation

final class TextEditorCoordinator: BaseCoordinator, TextEditorCoordinatorType {
    private weak var parentController: UIViewController?
    private let data: TextEditorData

    private var viewModel: TextEditorNavigationEmittable?

    private lazy var viewController: UIViewController = { [weak self] in
        let vm = TextEditorViewModel(data: self!.data)
        self?.viewModel = vm
        return TextEditorViewController(viewModel: vm)
    }()
    override var rootViewController: UIViewController { viewController }

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
    
    override func setup() {
        super.setup()
        viewModel?.needSaveAndClose.emit(onNext: { [weak self] result in
            guard let self else { return }
            self.finishResultRelay.accept(result)
            self.rootViewController.dismiss(animated: true)
        })
        .disposed(by: disposeBag)
    }

}
