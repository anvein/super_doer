import UIKit

class TaskDeadlineDateVariantsCoordinator: BaseCoordinator {
    private var navigation: UINavigationController
    private var viewModel: TaskDeadlineTableVariantsViewModel

    
    private var currentNavigation: ContainerNavigationController?
    
    init(
        parent: Coordinator,
        navigation: UINavigationController,
        viewModel: TaskDeadlineTableVariantsViewModel,
        delegate: TaskDeadlineDateVariantsCoordinatorDelegate
    ) {
        self.navigation = navigation
        self.viewModel = viewModel
//        self.delegate = delegate
        super.init(parent: parent)
    }
    
    override func start() {
        super.start()

        let controller = TableVariantsViewController(
            viewModel: viewModel,
            coordinator: self,
            settingsCode: .taskDeadlineVariants
        )
        controller.title = "Срок"
        
        currentNavigation = ContainerNavigationController(
            rootViewController: controller,
            coordinator: self
        )
        guard let currentNavigation else { return }
        
        navigation.present(currentNavigation, animated: true)
    }
    
    
    // MARK: start child's coordinators
    private func startCustomTaskDeadlineSetterCoordinator() {
        guard let currentNavigation else { return }
        
        let viewModel = viewModel.getTaskDeadlineCustomDateSetterViewModel()
        let coordinator = TaskDeadlineDateCustomCoordinator(
            parent: self,
            navigation: currentNavigation,
            viewModel: viewModel,
            delegate: self
        )
        addChild(coordinator)
        coordinator.start()
    }
}

// MARK: - coordinator delegate protocol
protocol TaskDeadlineDateVariantsCoordinatorDelegate: AnyObject {
    func didChooseTaskDeadlineDate(newDate: Date?)
}


// MARK: - coordinator methods for TableVariantsViewController
extension TaskDeadlineDateVariantsCoordinator: TableVariantsViewControllerCoordinator {
    func didChooseDateVariant(newDate: Date?) {
//        delegate?.didChooseTaskDeadlineDate(newDate: newDate)
    }
    
    func didChooseCustomVariant() {
        startCustomTaskDeadlineSetterCoordinator()
    }
    
    func didChooseDeleteVariantButton() {
//        delegate?.didChooseTaskDeadlineDate(newDate: nil)
    }
}


// MARK: - coordinator methods for ContainerNavigationController
extension TaskDeadlineDateVariantsCoordinator: ContainerNavigationControllerCoordinator {
    func didCloseContainerNavigation() {
        parent?.removeChild(self)
    }
}


// MARK: - delegates of child coordinators
extension TaskDeadlineDateVariantsCoordinator: TaskDeadlineDateCustomCoordinatorDelegate {
    func didChooseTaskDeadlineDate(newDate: Date?) {
//        self.delegate?.didChooseTaskDeadlineDate(newDate: newDate)
    }
}
