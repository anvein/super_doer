
import Swinject
import UserNotifications

final class DIContainer {
    static let shared = Container()
    
    private init() { }
    
    /// Надо вызвать, чтобы зарегистрировались зависимости
    static func registerDependencies() {
        // MARK: Service

        Self.shared.register(NotificationsService.self) { _ in
            return NotificationsService(
                notificationCenter: UNUserNotificationCenter.current()
            )
        }.inObjectScope(.container)


        Self.shared.register(SystemSectionsBuilder.self) { _ in
            return SystemSectionsBuilder()
        }.inObjectScope(.container)
        
        
        // MARK: - CoreData services

        Self.shared.register(TaskSectionEntityManager.self, factory: { _ in
            return TaskSectionEntityManager()
        }).inObjectScope(.container)
        
        Self.shared.register(TaskCoreDataManager.self, factory: { _ in
            return TaskCoreDataManager()
        }).inObjectScope(.container)
        
        Self.shared.register(TaskFileEntityManager.self) { _ in
            return TaskFileEntityManager()
        }.inObjectScope(.container)
        
        
        // MARK: Coordinators     

        Self.shared.register(AppCoordinator.self) { r, arg1 in
            return AppCoordinator(
                window: arg1,
                sectionEm: r.resolve(TaskSectionEntityManager.self)!,
                systemSectionsBuilder: r.resolve(SystemSectionsBuilder.self)!
            )
        }.inObjectScope(.container)
    
        
        // MARK: ViewController
        
        
        
        
        // MARK: ViewModel
     
        // MARK: - Models

        Self.shared.register(TasksListModel.self) { r, arg1 in
            return TasksListModel(
                taskSection: arg1,
                taskCDManager: r.resolve(TaskCoreDataManager.self)!
            )
        }.inObjectScope(.container)
    }
    
}
