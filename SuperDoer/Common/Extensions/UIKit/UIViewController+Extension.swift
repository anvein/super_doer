import UIKit
import RxCocoa

extension UIViewController {

    func showErrorAlert(
        message: String,
        title: String? = "Ошибка",
        actionTitle: String = "ОК"
    ) {
        let alert = UIAlertController(
            title: title,
            message: message,
            preferredStyle: .alert
        )

        alert.addAction(UIAlertAction(title: actionTitle, style: .default))

        DispatchQueue.main.async {
            self.present(alert, animated: true)
        }
    }
}

// MARK: - DismissableController

private var didDismissRelayKey: UInt8 = 0

extension UIViewController: DismissableController {
    var didDismiss: Signal<Void> {
        if let relay = objc_getAssociatedObject(self, &didDismissRelayKey) as? PublishRelay<Void> {
            return relay.asSignal()
        }

        let relay = PublishRelay<Void>()
        objc_setAssociatedObject(self, &didDismissRelayKey, relay, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)

        _ = rx.methodInvoked(#selector(UIViewController.viewDidDisappear))
            .filter { [weak self] _ in
                guard let self else { return false }
                return self.isBeingDismissed || self.isMovingFromParent
            }
            .map { _ in }
            .bind(to: relay)

        return relay.asSignal()
    }
}
