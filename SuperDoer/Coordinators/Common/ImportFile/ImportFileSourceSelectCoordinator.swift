import UIKit
import RxRelay
import RxCocoa
import RxSwift

typealias AddFileSource = ImportFileSourceSelectCoordinator.Source

class ImportFileSourceSelectCoordinator: BaseCoordinator {
    enum Source {
        case library
        case camera
        case files
    }

    let disposeBag = DisposeBag()

    private var parentController: UIViewController
    private let alertFactory: ImportFileSourceAlertFactory

    private let finishResultRelay = PublishRelay<ImportFileSourceAlertFactory.FileSource?>()
    var finishResult: Signal<ImportFileSourceAlertFactory.FileSource?> {
        finishResultRelay.asSignal()
    }

    // MARK: - Init

    init(
        parent: Coordinator,
        parentController: UIViewController,
        alertFactory: ImportFileSourceAlertFactory
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

extension ImportFileSourceSelectCoordinator: ImportFileSourceAlertDelegate {
    func didChooseImportFileSource(_ source: ImportFileSourceAlertFactory.FileSource) {
        finishResultRelay.accept(source)
        finish()
    }

    func didChooseImportFileSourceCancel() {
        finishResultRelay.accept(nil)
        finish()
    }
}
