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

    func makeDependency(section: TasksListSection) -> TasksListDependency {
        let vm = TasksListViewModel(
            section: section,
            listRepository: resolver.resolve(TasksListRepository.self)!,
            sectionRepository: resolver.resolve(TaskSectionRepository.self)!,
            taskRepository: resolver.resolve(TaskRepository.self)!
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
