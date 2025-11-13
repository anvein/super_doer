import UIKit

class TaskRepeatPeriodCusomSelectorCoordinator: BaseCoordinator {

    private var viewModel:  RepeatPeriodSelectorViewModel
    private let viewController: RepeatPeriodSelectorViewController

    override var rootViewController: UIViewController { viewController }
    
    init(parent: Coordinator) {
        let vm = RepeatPeriodSelectorViewModel(repeatPeriod: "1d")
        self.viewModel = vm

        self.viewController = RepeatPeriodSelectorViewController(viewModel: vm)
        super.init(parent: parent)
    }
    
    override func setup() {
        super.setup()

        viewController.title = "Повторять каждые"
    }
    
}
