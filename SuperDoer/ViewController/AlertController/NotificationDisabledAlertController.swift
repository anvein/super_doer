
import UIKit

/// Уведомление об отключенных уведомлениях
/// с предложением их включить
class NotificationDisabledAlertController: UIAlertController {
    
    var actionEnableNotifications: UIAlertAction
    var actionCancel: UIAlertAction
    
    init(title: String? = nil, message: String? = nil) {
        actionEnableNotifications = UIAlertAction(
            title: "Включить уведомления",
            style: .default,
            handler: { actionEnableNotifications in
                NotificationDisabledAlertController.openNotificationsSettings()
            }
        )
        
        actionCancel = UIAlertAction(title: "Не сейчас", style: .destructive)
        
        super.init(nibName: nil, bundle: nil)
        
        self.title = title ?? "Уведомления выключены"
        self.message = message ?? "Нам нужно ваше разрешение для напоминаний.\nВключите уведомления в разделе \"Параметры\" > \"Уведомления\""
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        addAction(actionEnableNotifications)
        addAction(actionCancel)
    }
    
    static func openNotificationsSettings() {
        // TODO: открыть настройки уведомлений
        print("Открыть настройки уведомлений")
    }

}
