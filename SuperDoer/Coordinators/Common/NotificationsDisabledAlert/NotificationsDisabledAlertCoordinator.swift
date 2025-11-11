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

    override var rootViewController: UIViewController { alertController }
    private lazy var alertController: UIAlertController = { [unowned self] in
        return self.alertFactory.makeAlert { [weak self] answer in
            self?.handleAlertAnswer(answer)
        }
    }()

    private let alertFactory: NotificationsDisabledAlertFactory

    private let finishResultRelay = PublishRelay<FinishResult>()
    var finishResult: Signal<FinishResult> { finishResultRelay.asSignal() }

    override var isAutoFinishEnabled: Bool { false }

    init(
        parent: Coordinator,
        alertFactory: NotificationsDisabledAlertFactory
    ) {
        self.alertFactory = alertFactory
        super.init(parent: parent)
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
