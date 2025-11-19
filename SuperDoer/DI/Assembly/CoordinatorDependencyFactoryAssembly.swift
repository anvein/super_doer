import Swinject

final class CoordinatorDependencyFactoryAssembly: Assembly {
    func assemble(container: Container) {
        container.register(SectionsListDependencyFactoryType.self) { r in
            SectionsListDependencyFactory(resolver: r)
        }.inObjectScope(.container)

        container.register(TasksListDependencyFactoryType.self) { r in
            TasksListDependencyFactory(resolver: r)
        }.inObjectScope(.container)

        container.register(TaskDetailDependencyFactoryType.self) { r in
            TaskDetailDependencyFactory(resolver: r)
        }.inObjectScope(.container)

        container.register(TaskDeadlineVariantsFactoryType.self) { r in
            TaskDeadlineVariantsFactory(resolver: r)
        }.inObjectScope(.container)

        container.register(TaskRepeatPeriodVariantsFactory.self) { r in
            TaskRepeatPeriodVariantsFactory(resolver: r)
        }.inObjectScope(.container)
    }

}
