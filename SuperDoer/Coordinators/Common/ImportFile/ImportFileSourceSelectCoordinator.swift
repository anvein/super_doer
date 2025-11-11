import UIKit
import RxRelay
import RxCocoa
import RxSwift

class ImportFileSourceSelectCoordinator: BaseCoordinator {

    override var rootViewController: UIViewController { alertController }
    private lazy var alertController: UIAlertController = { [unowned self] in
        return self.alertFactory.makeAlert { [weak self] answer in
            self?.handleAlertAnswer(answer)
        }
    }()

    private let alertFactory: ImportFileSourceAlertFactory

    private let finishResultRelay = PublishRelay<ImportFileSource?>()
    var finishResult: Signal<ImportFileSource?> { finishResultRelay.asSignal() }

    override var isAutoFinishEnabled: Bool { false }

    // MARK: - Init

    init(parent: Coordinator, alertFactory: ImportFileSourceAlertFactory) {
        self.alertFactory = alertFactory
        super.init(parent: parent)
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
