import Swinject

final class AlertFactoryAssembly: Assembly {
    func assemble(container: Container) {
        container.register(DeleteItemsAlertFactory.self) { _ in
            DeleteItemsAlertFactory()
        }.inObjectScope(.container)

        container.register(ImportFileSourceAlertFactory.self) { _ in
            ImportFileSourceAlertFactory()
        }.inObjectScope(.container)

        container.register(NotificationsDisabledAlertFactory.self) { _ in
            NotificationsDisabledAlertFactory()
        }.inObjectScope(.container)

    }

}
