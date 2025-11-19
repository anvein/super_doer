import Swinject

final class AppDI {
    let container: Container
    let assembler: Assembler

    init() {
        self.container = Container()
        self.assembler = Assembler(
            [
                AlertFactoryAssembly(),
                CoreDataManagerAssembly(),
                DataFactoryAssembly(),
                RepositoryAssembly(),
                ServiceAssembly(),
                CoordinatorDependencyFactoryAssembly(),
            ],
            container: container
        )
    }

}
