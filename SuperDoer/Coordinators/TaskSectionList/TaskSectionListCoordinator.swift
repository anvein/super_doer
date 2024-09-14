
import UIKit

final class TaskSectionListCoordinator: BaseCoordinator {
    
    private var navigation: UINavigationController
    private var viewModel: TaskSectionsListViewModel
    
    init(
        parent: Coordinator,
        navigation: UINavigationController,
        viewModel: TaskSectionsListViewModel
    ) {
        self.navigation = navigation
        self.viewModel = viewModel
        super.init(parent: parent)
    }
    
    override func start() {
        let taskSectionVM = viewModel
        let taskSectionListVC = TaskSectionsListViewController(
            coordinator: self,
            viewModel: taskSectionVM
        )
        
        navigation.pushViewController(taskSectionListVC, animated: false)
    }
}


// MARK: - coordinator methods
extension TaskSectionListCoordinator: TaskSectionsListViewControllerCoordinator {
    func selectTaskSection(viewModel: TasksListInSectionViewModel) {
        let coordinator = TaskListInSectionCoordinator(
            parent: self,
            navigation: navigation,
            viewModel: viewModel
        )
        addChild(coordinator)
        coordinator.start()
    }
    
    func startDeleteProcessSection(_ sectionVM: TaskSectionDeletableViewModel) {
        let coordinator = DeleteItemCoordinator(
            parent: self,
            navigation: navigation,
            viewModels: [sectionVM],
            delegate: self
        )
        addChild(coordinator)
        coordinator.start()
    }
    
    func closeTaskSectionsList() {
        parent?.removeChild(self)
    }
}


// MARK: - DeleteItemCoordinatorDelegate
extension TaskSectionListCoordinator: DeleteItemCoordinatorDelegate {
    func didConfirmDeleteItems(_ items: [DeletableItemViewModelType]) {
        guard let sectionVM = items.first as? TaskSectionDeletableViewModel else {
            return
        }
        viewModel.deleteCustomSection(sectionViewModel: sectionVM)
    }
}
