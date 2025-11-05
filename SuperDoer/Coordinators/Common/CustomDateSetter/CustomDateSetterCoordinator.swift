import UIKit

class CustomDateSetterCoordinator: BaseCoordinator {
    private var navigation: UINavigationController
    private var viewModel: TaskDeadlineDateCustomViewModel?
    private weak var delegate: TaskDeadlineDateCustomCoordinatorDelegate?

    private let value: Date?

    init(
        parent: Coordinator,
        navigation: UINavigationController,
        delegate: TaskDeadlineDateCustomCoordinatorDelegate,
        value: Date?
    ) {
        self.navigation = navigation
        self.delegate = delegate
        self.value = value
        super.init(parent: parent)
    }
    
    override func start() {
        super.start()

        let viewModel = TaskDeadlineDateCustomViewModel(taskDeadlineDate: value)

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
extension CustomDateSetterCoordinator: CustomDateSetterViewControllerCoordinator {
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
