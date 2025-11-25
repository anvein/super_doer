import Swinject

// swiftlint:disable force_unwrapping
final class SectionsListDependencyFactory: SectionsListDependencyFactoryType {
    private let resolver: Resolver

    lazy var tasksListFactory: TasksListDependencyFactoryType = {
        resolver.resolve(TasksListDependencyFactoryType.self)!
    }()

    init(resolver: Resolver) {
        self.resolver = resolver
    }

    func makeDependency() -> SectionsListDependency {
        let vm = SectionsListViewModel(
            repository: resolver.resolve(TaskSectionRepository.self)!
        )
        let vc = SectionsListViewController(viewModel: vm)

        return .init(
            viewController: vc,
            viewModel: vm,
            deleteAlertFactory: resolver.resolve(DeleteItemsAlertFactory.self)!
        )
    }

}
// swiftlint:enable force_unwrapping
