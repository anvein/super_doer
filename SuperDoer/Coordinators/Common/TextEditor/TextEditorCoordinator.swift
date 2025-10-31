import UIKit
import RxRelay
import RxCocoa
import RxSwift
import Foundation

class TextEditorCoordinator: BaseCoordinator, TextEditorCoordinatorType {
    let disposeBag = DisposeBag()

    private weak var parentController: UIViewController?
    private let data: TextEditorData

    private var viewModel: TextEditorNavigationEmittable?

    private let didFinishWithResultRelay = PublishRelay<NSAttributedString?>()
    var didFinishWithResultSignal: Signal<NSAttributedString?> {
        didFinishWithResultRelay.asSignal()
    }

    init(
        parent: Coordinator,
        parentVC: UIViewController,
        data: TextEditorData
    ) {
        self.parentController = parentVC
        self.data = data
        super.init(parent: parent)
    }
    
    override func start() {
        super.start()

        let vm = TextEditorViewModel(data: data)
        let vc = TextEditorViewController(viewModel: vm)
        viewModel = vm

        viewModel?.didCloseWithSave.emit(onNext: { [weak self] result in
            self?.didFinishWithResultRelay.accept(result)
            self?.finish()
        })
        .disposed(by: disposeBag)

        parentController?.present(vc, animated: true)
    }

}
