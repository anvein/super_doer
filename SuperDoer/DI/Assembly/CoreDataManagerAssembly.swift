import Swinject

// swiftlint:disable force_unwrapping
final class CoreDataManagerAssembly: Assembly {
    func assemble(container: Container) {
        container.register(CoreDataStack.self) { _ in
            CoreDataStack(modelName: CoreDataStack.mainModelName)
        }.inObjectScope(.container)

        container.register(TaskCoreDataSource.self) { r in
            TaskCoreDataSource(
                coreDataStack: r.resolve(CoreDataStack.self)!
            )
        }.inObjectScope(.container)

        container.register(TaskSectionCoreDataSource.self) { r in
            TaskSectionCoreDataSource(
                coreDataStack: r.resolve(CoreDataStack.self)!
            )
        }
        .inObjectScope(.container)

        container.register(TaskFileCoreDataSource.self) { r in
            TaskFileCoreDataSource(
                coreDataStack: r.resolve(CoreDataStack.self)!
            )
        }.inObjectScope(.container)
    }

}
// swiftlint:enable force_unwrapping
