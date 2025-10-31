import UIKit
import RxRelay
import RxCocoa
import RxSwift

typealias AddFileSource = AddFileSourceSelectCoordinator.Source

class AddFileSourceSelectCoordinator: BaseCoordinator {
    enum Source {
        case library
        case camera
        case files
    }

    let disposeBag = DisposeBag()

    private var parentController: UIViewController
    private let alertFactory: AddFileSourceAlertFactory

    private let didCloseResultRelay = PublishRelay<AddFileSourceAlertFactory.FileSource?>()
    var didCloseResult: Signal<AddFileSourceAlertFactory.FileSource?> {
        didCloseResultRelay.asSignal()
    }

    // MARK: - Init

    init(
        parent: Coordinator,
        parentController: UIViewController,
        alertFactory: AddFileSourceAlertFactory
    ) {
        self.parentController = parentController
        self.alertFactory = alertFactory
        super.init(parent: parent)
    }
    
    override func start() {
        super.start()

        let alert = alertFactory.makeAlert(delegate: self)
        parentController.present(alert, animated: true)
    }
}

// MARK: - ImportFileSourceAlertDelegate

extension AddFileSourceSelectCoordinator: AddFileSourceAlertDelegate {
    func didChooseImportFileSource(_ source: AddFileSourceAlertFactory.FileSource) {
        didCloseResultRelay.accept(source)
        finish()
    }

    func didChooseImportFileSourceCancel() {
        didCloseResultRelay.accept(nil)
        finish()
    }
}
