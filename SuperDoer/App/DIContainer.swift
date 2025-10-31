import Swinject
import UserNotifications

final class DIContainer {
    static let container = Container()
    
    private init() { }

    static func registerDependencies() {

        // MARK: - Services

        Self.container.register(NotificationsService.self) { _ in
            return NotificationsService(
                notificationCenter: UNUserNotificationCenter.current()
            )
        }.inObjectScope(.container)

        Self.container.register(SystemSectionsBuilder.self) { _ in
            return SystemSectionsBuilder()
        }.inObjectScope(.container)

        Self.container.register(DeleteItemsAlertFactory.self) { _ in
            DeleteItemsAlertFactory()
        }.inObjectScope(.container)

        Self.container.register(AddFileSourceAlertFactory.self) { _ in
            AddFileSourceAlertFactory()
        }.inObjectScope(.container)

        // MARK: - CoreData services

        Self.container.register(TaskSectionCoreDataManager.self, factory: { _ in
            return TaskSectionCoreDataManager()
        }).inObjectScope(.container)
        
        Self.container.register(TaskCoreDataManager.self, factory: { _ in
            return TaskCoreDataManager()
        }).inObjectScope(.container)
        
        Self.container.register(TaskFileEntityManager.self) { _ in
            return TaskFileEntityManager()
        }.inObjectScope(.container)
        
        
        // MARK: Coordinators     

        Self.container.register(AppCoordinator.self) { r, window, navigation in
            return AppCoordinator(window: window, navigation: navigation)
        }.inObjectScope(.container)
    
        
        // MARK: ViewController
        
        
        
        
        // MARK: ViewModel
     
        // MARK: - Models

        Self.container.register(TasksListRepository.self) { r, arg1 in
            return TasksListRepository(
                sectionId: arg1,
                sectionCDManager: r.resolve(TaskSectionCoreDataManager.self)!,
                taskCDManager: r.resolve(TaskCoreDataManager.self)!
            )
        }.inObjectScope(.graph)
    }
    
}
