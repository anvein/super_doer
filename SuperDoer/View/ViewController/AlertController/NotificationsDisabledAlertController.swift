
import UIKit

/// Уведомление об отключенных уведомлениях
/// с предложением их включить
class NotificationsDisabledAlertController: UIAlertController {
    
    weak var delegate: NotificationsDisabledAlertControllerDelegate?
    
    
    // MARK: init
    init(title: String? = nil, message: String? = nil) {
        super.init(nibName: nil, bundle: nil)
        
        self.title = title ?? "Уведомления выключены"
        self.message = message ?? "Нам нужно ваше разрешение для напоминаний.\nВключите уведомления в разделе \"Параметры\" > \"Уведомления\""
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
            handler: { actionEnableNotifications in
                self.delegate?.didChoosenEnableNotifications()
            }
        )
        
        let actionNotNow = UIAlertAction(title: "Не сейчас", style: .destructive, handler: { action in
            self.delegate?.didChoosenNotNowEnableNotification()
        })
        
        let actionCancel = UIAlertAction(title: "Отмена", style: .cancel)
        
        addAction(actionEnableNotifications)
        addAction(actionNotNow)
        addAction(actionCancel)
    }
    
    
    // MARK: other methods

}


// MARK: delegate
protocol NotificationsDisabledAlertControllerDelegate: AnyObject {
    /// Был выбран вариант "Включить уведомления" (в настройках)
    func didChoosenEnableNotifications()
    
    /// Был выбран вариант "Не сейчас" (включать уведомления в настройках)
    func didChoosenNotNowEnableNotification()
}
