
import UserNotifications

final class NotificationsService {


    private let notificationCenter: UNUserNotificationCenter


    init(notificationCenter: UNUserNotificationCenter) {
        self.notificationCenter = notificationCenter
    }

    func requestNotification() {

        notificationCenter.requestAuthorization(
            options: [.badge, .sound, .alert]) { granted, error in
                if granted {
                    
                }
            }
    }

//    func currentAuthStatus() async {
//        return await notificationCenter.notificationSettings().authorizationStatus
//
//
//
//
//
////        { settings in
////            switch settings.authorizationStatus {
////            case .notDetermined:
////                print("Разрешение на уведомления еще не запрашивалось")
////            case .denied:
////                print("Пользователь отказал в разрешении на уведомления")
////            case .authorized:
////                print("Пользователь разрешил уведомления")
////            case .provisional:
////                print("Пользователь предоставил временное разрешение на уведомления")
////            case .ephemeral:
////                print("Пользователь предоставил временное разрешение на уведомления для веб-приложений (только iOS 14.0+)")
////            @unknown default:
////                print("Неизвестный статус разрешения на уведомления")
////            }
////        }
//    }


}
