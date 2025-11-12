import UIKit
import RxRelay
import RxCocoa
import RxSwift
import Foundation

final class TextEditorCoordinator: BaseCoordinator, TextEditorCoordinatorType {
    private var viewModel: TextEditorNavigationEmittable?

    private let viewController: TextEditorViewController
    override var rootViewController: UIViewController { viewController }

    private let finishResultRelay = PublishRelay<NSAttributedString?>()
    var finishResult: Signal<NSAttributedString?> { finishResultRelay.asSignal() }

    init(
        parent: Coordinator,
        data: TextEditorData
    ) {
        let vm = TextEditorViewModel(data: data)
        self.viewModel = vm
        self.viewController = TextEditorViewController(viewModel: vm)
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
