
import UIKit

class TaskReminderCustomDateCoordinator: BaseCoordinator {
    private var navigation: UINavigationController
    private var viewModel: TaskReminderCustomDateViewModel
    private weak var delegate: TaskReminderCustomDateCoordinatorDelegate?
    
    private var currentNavigation: ContainerNavigationController?
    
    init(
        parent: Coordinator,
        navigation: UINavigationController,
        viewModel: TaskReminderCustomDateViewModel,
        delegate: TaskReminderCustomDateCoordinatorDelegate
    ) {
        self.navigation = navigation
        self.viewModel = viewModel
        self.delegate = delegate
        super.init(parent: parent)
    }
    
    override func start() {
        super.start()

        let controller = CustomDateSetterViewController(
            viewModel: viewModel,
            coordinator: self,
            datePickerMode: .dateAndTime
        )
        controller.title = "Напоминание"
        
        currentNavigation = ContainerNavigationController(
            rootViewController: controller,
            coordinator: self
        )
        
        guard let currentNavigation else { return }
        navigation.present(currentNavigation, animated: true)
    }
}


// MARK: - delegate protocol
protocol TaskReminderCustomDateCoordinatorDelegate: AnyObject {
    func didChooseTaskReminderDate(newDate: Date?)
}


// MARK: - coordinator methods for CustomDateSetterViewController
extension TaskReminderCustomDateCoordinator: CustomDateSetterViewControllerCoordinator {
    func didChooseCustomDateReady(newDate: Date?) {
        delegate?.didChooseTaskReminderDate(newDate: newDate)
    }
    
    func didChooseCustomDateDelete() {
        delegate?.didChooseTaskReminderDate(newDate: nil)
    }
    
    func didGoBackCustomDateSetter() {
        parent?.removeChild(self)
    }
}


// MARK: - coordinator methods for ContainerNavigationController
extension TaskReminderCustomDateCoordinator: ContainerNavigationControllerCoordinator {
    func didCloseContainerNavigation() {
        parent?.removeChild(self)
    }
}

