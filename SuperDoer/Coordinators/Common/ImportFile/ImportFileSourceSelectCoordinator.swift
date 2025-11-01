import UIKit
import RxRelay
import RxCocoa
import RxSwift

class ImportFileSourceSelectCoordinator: BaseCoordinator {

    let disposeBag = DisposeBag()

    private var parentController: UIViewController
    private let alertFactory: ImportFileSourceAlertFactory

    private let finishResultRelay = PublishRelay<ImportFileSource?>()
    var finishResult: Signal<ImportFileSource?> {
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

        let alert = alertFactory.makeAlert { [weak self] answer in
            self?.handleAlertAnswer(answer)
        }
        parentController.present(alert, animated: true)
    }

    private func handleAlertAnswer(_ answer: ImportFileSourceAlertAnswer) {
        switch answer {
        case .selectedSource(let source):
            finishResultRelay.accept(source)

        case .cancel:
            finishResultRelay.accept(nil)
        }

        finish()
    }
}
