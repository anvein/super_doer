import UIKit

class TaskRepeatPeriodCusomCoordinator: BaseCoordinator {

    private var viewModel:  CustomTaskRepeatPeriodSetterViewModel
    private let viewController: CustomTaskRepeatPeriodSetterViewController

    override var rootViewController: UIViewController { viewController }
    private weak var delegate: TaskRepeatPeriodCusomCoordinatorDelegate?
    
    init(
        parent: Coordinator,
        navigation: UINavigationController,
        viewModel: CustomTaskRepeatPeriodSetterViewModel,
        delegate: TaskRepeatPeriodCusomCoordinatorDelegate
    ) {
        let vm = CustomTaskRepeatPeriodSetterViewModel(repeatPeriod: "1d")
        self.viewModel = vm

        self.viewController = CustomTaskRepeatPeriodSetterViewController(viewModel: vm)

        self.delegate = delegate
        super.init(parent: parent)
    }
    
    override func setup() {
        super.setup()

        viewController.title = "Повторять каждые"
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
