
import UIKit

class NotificationsDisabledAlertCoordinator: BaseCoordinator {
    private var navigation: UINavigationController
    weak var delegate: NotificationsDisabledAlertCoordinatorDelegate?
        
    init(
        parent: Coordinator,
        navigation: UINavigationController,
        delegate: NotificationsDisabledAlertCoordinatorDelegate
    ) {
        self.navigation = navigation
        self.delegate = delegate
        super.init(parent: parent)
    }
    
    override func start() {
        let alertController = NotificationsDisabledAlertController(coordinator: self)
        
        navigation.present(alertController, animated: true)
    }
}


// MARK: delegate
protocol NotificationsDisabledAlertCoordinatorDelegate: AnyObject {
    func didChoosenEnableNotifications()
    
    func didChoosenNotNowEnableNotification()
}


// MARK: alert controller coordinator
extension NotificationsDisabledAlertCoordinator: NotificationsDisabledAlertControllerCoordinator {
    func didChoosenEnableNotifications() {
        // TODO: реализовать настройки уведомлений
        let url = URL(string: UIApplication.openNotificationSettingsURLString)
        guard let url else { return }
        
        UIApplication.shared.open(url)
        delegate?.didChoosenEnableNotifications()
    }
    
    func didChoosenNotNowEnableNotification() {
        self.delegate?.didChoosenNotNowEnableNotification()
    }
    
    func didChooseCancelNotificationsAlert() {
        parent?.removeChild(self)
    }
    
    func didCloseNotificationsAlert() {
        parent?.removeChild(self)
    }
    
}
