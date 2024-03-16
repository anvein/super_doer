
import UIKit

final class TaskSectionListCoordinator: BaseCoordinator {
    
    private var navigation: UINavigationController
    
    init(parent: Coordinator, navigation: UINavigationController) {
        self.navigation = navigation
        super.init(parent: parent)
    }
    
    override func start() {
        let taskSectionVM = DIContainer.shared.resolve(TaskSectionListViewModel.self)!
        let taskSectionListVC = TaskSectionsListViewController(
            coordinator: self,
            viewModel: taskSectionVM
        )
        
        navigation.pushViewController(taskSectionListVC, animated: false)
    }
    
}

extension TaskSectionListCoordinator: TaskSectionsListViewControllerCoordinator {
    func selectTaskSection(viewModel: TaskListInSectionViewModel) {
        let coordinator = TaskListInSectionCoordinator(
            parent: self,
            navigation: navigation,
            viewModel: viewModel
        )
        addChild(coordinator)
        coordinator.start()
    }
    
    func closeTaskSectionsList() {
        parent?.removeChild(self)
    }
}
