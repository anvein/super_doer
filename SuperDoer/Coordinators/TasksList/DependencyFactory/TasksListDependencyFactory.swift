import Swinject
import Foundation

// swiftlint:disable force_unwrapping
final class TasksListDependencyFactory: TasksListDependencyFactoryType {

    private let resolver: Resolver

    var taskDetailFactory: any TaskDetailDependencyFactoryType {
        resolver.resolve(TaskDetailDependencyFactoryType.self)!
    }

    init(resolver: Resolver) {
        self.resolver = resolver
    }

    func makeDependency(sectionId: UUID?) -> TasksListDependency {
        let vm = TasksListViewModel(
            repository: resolver.resolve(TasksListRepository.self, argument: sectionId)!,
            sectionCDManager: resolver.resolve(TaskSectionCoreDataManager.self)!
        )

        let vc = TasksListViewController(viewModel: vm)

        return .init(
            viewModel: vm,
            viewController: vc,
            deleteAlertFactory: resolver.resolve(DeleteItemsAlertFactory.self)!
        )
    }

}
// swiftlint:enable force_unwrapping
