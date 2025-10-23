import UIKit

class NotificationsDisabledAlertController: UIAlertController {
    
    private var coordinator: NotificationsDisabledAlertControllerCoordinator?
    
    
    // MARK: init
    init(
        coordinator: NotificationsDisabledAlertControllerCoordinator,
        title: String? = nil,
        message: String? = nil
    ) {
        super.init(nibName: nil, bundle: nil)
        self.coordinator = coordinator
    
        self.title = title ?? "Уведомления выключены"
        self.message = message ?? """
                                  Нам нужно ваше разрешение для напоминаний.
                                  Включите уведомления в разделе \"Параметры\" > \"Уведомления\"
                                  """
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
    // MARK: lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let actionEnableNotifications = UIAlertAction(
            title: "Включить уведомления",
            style: .default,
            handler: { [weak self] _ in
                self?.coordinator?.didChoosenEnableNotifications()
            }
        )
        
        let actionNotNow = UIAlertAction(
            title: "Не сейчас",
            style: .destructive,
            handler: { [weak self] _ in
            self?.coordinator?.didChoosenNotNowEnableNotification()
        })
        
        let actionCancel = UIAlertAction(
            title: "Отмена",
            style: .cancel) { [weak self] _ in
                self?.coordinator?.didChooseCancelNotificationsAlert()
            }
        
        addAction(actionEnableNotifications)
        addAction(actionNotNow)
        addAction(actionCancel)
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)

        if isMovingFromParent {
            coordinator?.didCloseNotificationsAlert()
        }
    }
}


// MARK: delegate
protocol NotificationsDisabledAlertControllerCoordinator: AnyObject {
    /// Был выбран вариант "Включить уведомления" (в настройках)
    func didChoosenEnableNotifications()
    
    /// Был выбран вариант "Не сейчас" (включать уведомления в настройках)
    func didChoosenNotNowEnableNotification()
    
    /// Был выбран вариант "Отмена"
    func didChooseCancelNotificationsAlert()
    
    // Алерт был закрыт без выбора действия
    func didCloseNotificationsAlert()
}
