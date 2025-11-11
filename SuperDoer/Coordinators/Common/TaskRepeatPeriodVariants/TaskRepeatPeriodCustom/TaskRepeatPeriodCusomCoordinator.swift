import UIKit

class TaskRepeatPeriodCusomCoordinator: BaseCoordinator {

    override var rootViewController: UIViewController { viewController }
    private lazy var viewController: CustomTaskRepeatPeriodSetterViewController = { [weak self] in
        let vm = CustomTaskRepeatPeriodSetterViewModel(repeatPeriod: "1d")
        let viewController = CustomTaskRepeatPeriodSetterViewController(
            coordinator: self!,
            viewModel: vm
        )
        viewController.title = "Повторять каждые"
        self?.viewModel = vm

        return viewController
    }()

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
    
    override func setup() {
        super.setup()
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
