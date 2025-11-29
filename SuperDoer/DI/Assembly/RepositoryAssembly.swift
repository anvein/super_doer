import Swinject

// swiftlint:disable force_unwrapping
final class RepositoryAssembly: Assembly {
    func assemble(container: Container) {
        container.register(TaskSectionRepository.self) { r in
            return TaskSectionRepository(
                coreDataSource: r.resolve(TaskSectionCoreDataSource.self)!,
                coreDataStack: r.resolve(CoreDataStack.self)!,
                systemSectionsFactory: r.resolve(SystemSectionsFactory.self)!
            )
        }.inObjectScope(.container)

        container.register(TaskRepository.self) { r in
            return TaskRepository(
                coreDataStack: r.resolve(CoreDataStack.self)!,
                taskCoreDataSource: r.resolve(TaskCoreDataSource.self)!,
                sectionCoreDataSource: r.resolve(TaskSectionCoreDataSource.self)!,
                taskFileCoreDataSource: r.resolve(TaskFileCoreDataSource.self)!
            )
        }.inObjectScope(.container)

        container.register(TasksListRepository.self) { r in
            return TasksListRepository(
                sectionCDManager: r.resolve(TaskSectionCoreDataSource.self)!,
                taskCDManager: r.resolve(TaskCoreDataSource.self)!,
                coreDataStack: r.resolve(CoreDataStack.self)!
            )
        }.inObjectScope(.container)
    }

}
// swiftlint:enable force_unwrapping
