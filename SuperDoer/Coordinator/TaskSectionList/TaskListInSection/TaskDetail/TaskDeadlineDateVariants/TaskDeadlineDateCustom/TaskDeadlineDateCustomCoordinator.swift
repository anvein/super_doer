
import UIKit

class TaskDeadlineDateCustomCoordinator: BaseCoordinator {
    private var navigation: UINavigationController
    private var viewModel: TaskDeadlineDateCustomViewModel
    private weak var delegate: TaskDeadlineDateCustomCoordinatorDelegate?
     
    init(
        parent: Coordinator,
        navigation: UINavigationController,
        viewModel: TaskDeadlineDateCustomViewModel,
        delegate: TaskDeadlineDateCustomCoordinatorDelegate
    ) {
        self.navigation = navigation
        self.viewModel = viewModel
        self.delegate = delegate
        super.init(parent: parent)
    }
    
    override func start() {
        let controller = CustomDateSetterViewController(
            viewModel: viewModel,
            coordinator: self,
            datePickerMode: .date
        )
        navigation.pushViewController(controller, animated: true)
    }
    
}


// MARK: - delegate protocol
protocol TaskDeadlineDateCustomCoordinatorDelegate: AnyObject {
    func didChooseTaskDeadlineDate(newDate: Date?)
}


// MARK: - coordinator methods for CustomDateSetterViewController
extension TaskDeadlineDateCustomCoordinator: CustomDateSetterViewControllerCoordinator {
    func didChooseCustomDateReady(newDate: Date?) {
        delegate?.didChooseTaskDeadlineDate(newDate: newDate)
    }
    
    func didChooseCustomDateDelete() {
        delegate?.didChooseTaskDeadlineDate(newDate: nil)
    }
    
    func didGoBackCustomDateSetter() {
        parent?.removeChild(self)
    }
}
