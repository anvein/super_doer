
import UIKit

class TaskDescriptionEditorCoordinator: BaseCoordinator {
    private var navigation: UINavigationController
    private var viewModel: TaskDescriptionEditorViewModel
    private weak var delegate: TaskDescriptionEditorCoordinatorDelegate?
    
    init(
        parent: Coordinator,
        navigation: UINavigationController,
        viewModel: TaskDescriptionEditorViewModel,
        delegate: TaskDescriptionEditorCoordinatorDelegate
    ) {
        self.navigation = navigation
        self.viewModel = viewModel
        self.delegate = delegate
        super.init(parent: parent)
    }
    
    override func start() {
        let controller = TextEditorViewController(
            coordinator: self,
            viewModel: viewModel
        )
        navigation.present(controller, animated: true)
    }
}


// MARK: coordinator delegate protocol
protocol TaskDescriptionEditorCoordinatorDelegate: AnyObject {
    func didChooseTaskDescription(text: NSAttributedString)
}


// MARK: - coordinator methods for TextEditorViewController
extension TaskDescriptionEditorCoordinator: TextEditorViewControllerCoordinator {
    func didDisappearTextEditorViewController(text: NSAttributedString, isSuccess: Bool) {
        parent?.removeChild(self)
        delegate?.didChooseTaskDescription(text: text)
    }
}
