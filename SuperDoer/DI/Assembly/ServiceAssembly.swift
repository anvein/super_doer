import Swinject
import UserNotifications

final class ServiceAssembly: Assembly {
    func assemble(container: Container) {
        container.register(NotificationsService.self) { _ in
            return NotificationsService(
                notificationCenter: UNUserNotificationCenter.current()
            )
        }.inObjectScope(.container)

        container.register(TaskDeadlineTableVariantFinder.self) { _ in
            TaskDeadlineTableVariantFinder()
        }.inObjectScope(.container)

        container.register(TaskRepeatPeriodTableVariantFinder.self) { _ in
            TaskRepeatPeriodTableVariantFinder()
        }.inObjectScope(.container)
    }

}
