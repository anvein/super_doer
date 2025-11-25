import Swinject

final class CoreDataManagerAssembly: Assembly {
    func assemble(container: Container) {
        container.register(TaskSectionCoreDataManager.self) { _ in
            return TaskSectionCoreDataManager()
        }
        .inObjectScope(.container)

        container.register(
            TaskCoreDataManager.self,
            factory: { _ in
                return TaskCoreDataManager()
            }
        ).inObjectScope(.container)

        container.register(TaskFileCoreDataManager.self) { _ in
            return TaskFileCoreDataManager()
        }.inObjectScope(.container)
    }

}
