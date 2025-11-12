import UIKit

final class TaskRepeatPeriodVariantsCoordinator: BaseCoordinator {

    override var rootViewController: UIViewController { .init() }
    private var viewController: TableVariantsViewController?

    private var navigation: UINavigationController
    private var viewModel: TaskRepeatPeriodVariantsViewModel
    private weak var delegate: TaskRepeatPeriodVariantsCoordinatorDelegate?
    
    private var currentNavigation: UINavigationController?

    init(
        parent: Coordinator?,
        navigation: UINavigationController,
        viewModel: TaskRepeatPeriodVariantsViewModel,
        delegate: TaskRepeatPeriodVariantsCoordinatorDelegate
    ) {
        self.navigation = navigation
        self.viewModel = viewModel
        self.delegate = delegate
        super.init(parent: parent)
    }
    
    override func setup() {
        super.setup()
//        let controller = TableVariantsViewController(
//            viewModel: viewModel,
//            coordinator: self,
//            settingsCode: .taskRepeatPeriodVariants
//        )
//        controller.title = "Повтор"
//        
//        currentNavigation = ContainerNavigationController(
//            rootViewController: controller,
//            coordinator: self
//        )
//        guard let currentNavigation else { return }
//
//        navigation.present(currentNavigation, animated: true)
    }
    
    
    // MARK: start child coordinators
    func startCustomTaskRepeatPeriodCoordinator() {
        guard let currentNavigation else { return }
        
        let viewModel = viewModel.getCustomTaskRepeatPeriodSetterViewModel()
        let coordinator = TaskRepeatPeriodCusomCoordinator(
            parent: self,
            navigation: currentNavigation,
            viewModel: viewModel,
            delegate: self
        )
        startChild(coordinator) { [weak self] controller in
            self?.rootViewController.show(controller, sender: nil)
        }
    }
}


// MARK: - coordinator delegate protocol
protocol TaskRepeatPeriodVariantsCoordinatorDelegate: AnyObject {
    func didChooseTaskRepeatPeriod(newPeriod: String?)
}


//// MARK: - coordinator methods for TableVariantsViewController
//extension TaskRepeatPeriodVariantsCoordinator: TableVariantsViewControllerCoordinator {
//    func didChooseTaskRepeatPeriodVariant(newRepeatPeriod: String?) {
//        delegate?.didChooseTaskRepeatPeriod(newPeriod: newRepeatPeriod)
//    }
//    
//    func didChooseCustomVariant() {
//        startCustomTaskRepeatPeriodCoordinator()
//    }
//    
//    func didChooseDeleteVariantButton() {
//        delegate?.didChooseTaskRepeatPeriod(newPeriod: nil)
//    }
//}



// MARK: - delegates of child coordinators
extension TaskRepeatPeriodVariantsCoordinator: TaskRepeatPeriodCusomCoordinatorDelegate {
    func didChooseTaskRepeatPeriod(newPeriod: String?) {
        self.delegate?.didChooseTaskRepeatPeriod(newPeriod: newPeriod)
    }
}
