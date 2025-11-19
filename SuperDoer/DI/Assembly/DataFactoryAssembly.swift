import Swinject

final class DataFactoryAssembly: Assembly {
    func assemble(container: Container) {
        container.register(TaskDeadlineVariantsItemsFactory.self) { _ in
            TaskDeadlineVariantsItemsFactory()
        }.inObjectScope(.container)

        container.register(TaskRepeatPeriodVariantsItemsFactory.self) { _ in
            TaskRepeatPeriodVariantsItemsFactory()
        }.inObjectScope(.container)

        container.register(SystemSectionsFactory.self) { _ in
            return SystemSectionsFactory()
        }.inObjectScope(.container)
    }

}
