import UIKit
import RxRelay
import RxCocoa
import RxSwift

class NotificationsDisabledAlertCoordinator: BaseCoordinator {
    enum FinishResult {
        case didSelectNotificationsEnable
        case didSelectNotNow
        case didSelectCancel
    }

    private var parentController: UIViewController
    private let alertFactory: NotificationsDisabledAlertFactory

    let disposeBag = DisposeBag()

    private let finishResultRelay = PublishRelay<FinishResult>()
    var finishResult: Signal<FinishResult> { finishResultRelay.asSignal() }

    init(
        parent: Coordinator,
        parentController: UIViewController,
        alertFactory: NotificationsDisabledAlertFactory
    ) {
        self.parentController = parentController
        self.alertFactory = alertFactory
        super.init(parent: parent)
    }
    
    override func start() {
        super.start()

        let alertController = alertFactory.makeAlert { [weak self] answer in
            self?.handleAlertAnswer(answer)
        }
        parentController.present(alertController, animated: true)
    }

    private func handleAlertAnswer(_ answer: NotificationsDisabledAlertAnswer) {
        switch answer {
        case .enableNotifications:
            let url = URL(string: UIApplication.openNotificationSettingsURLString)
            guard let url else { return }

            UIApplication.shared.open(url)

            finishResultRelay.accept(.didSelectNotificationsEnable)

        case .notNow:
            finishResultRelay.accept(.didSelectNotNow)

        case .cancel:
            finishResultRelay.accept(.didSelectCancel)
        }

        finish()
    }
}
