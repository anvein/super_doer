
import UIKit

class TaskRepeatPeriodCusomCoordinator: BaseCoordinator {
    
    private var navigation: UINavigationController
    private var viewModel:  CustomTaskRepeatPeriodSetterViewModel
    private weak var delegate: TaskRepeatPeriodCusomCoordinatorDelegate?
    
    init(
        parent: Coordinator,
        navigation: UINavigationController,
        viewModel: CustomTaskRepeatPeriodSetterViewModel,
        delegate: TaskRepeatPeriodCusomCoordinatorDelegate
    ) {
        self.navigation = navigation
        self.viewModel = viewModel
        self.delegate = delegate
        super.init(parent: parent)
    }
    
    override func start() {
        super.start()

        let viewController = CustomTaskRepeatPeriodSetterViewController(
            coordinator: self,
            viewModel: viewModel
        )
        viewController.title = "Повторять каждые"
        
        navigation.pushViewController(viewController, animated: true)
    }
    
}


// MARK: - delegate protocol
protocol TaskRepeatPeriodCusomCoordinatorDelegate: AnyObject {
    func didChooseTaskRepeatPeriod(newPeriod: String?)
}


// MARK: - coordinator methods for CustomTaskRepeatPeriodSetterViewController
extension TaskRepeatPeriodCusomCoordinator: CustomTaskRepeatPeriodSetterViewControllerCoordinator {
    func didChooseCustomTaskRepeatPeriodReady(newPeriod: String?) {
        delegate?.didChooseTaskRepeatPeriod(newPeriod: newPeriod)
    }
    
    func didGoBackCustomRepeatPeriodSetter() {
        parent?.removeChild(self)
    }
    
}
