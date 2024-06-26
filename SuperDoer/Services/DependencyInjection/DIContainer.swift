
import Swinject

final class DIContainer {
    static let shared = Container()
    
    private init() { }
    
    /// Надо вызвать, чтобы зарегистрировались зависимости
    static func registerDependencies() {
        // MARK: Service
        Self.shared.register(SystemSectionsBuilder.self) { _ in
            return SystemSectionsBuilder()
        }.inObjectScope(.container)
        
        
        // MARK: - CoreData services
        Self.shared.register(TaskSectionEntityManager.self, factory: { _ in
            return TaskSectionEntityManager()
        }).inObjectScope(.container)
        
        Self.shared.register(TaskEntityManager.self, factory: { _ in
            return TaskEntityManager()
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
        
    }
    
}
