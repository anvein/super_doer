
import UIKit

class DeleteItemCoordinator: BaseCoordinator {
    private var navigation: UINavigationController
    private var viewModels: [DeletableItemViewModelType]
    private weak var delegate: DeleteItemCoordinatorDelegate?
    
    init(
        parent: Coordinator,
        navigation: UINavigationController,
        viewModels: [DeletableItemViewModelType],
        delegate: DeleteItemCoordinatorDelegate
    ) {
        self.navigation = navigation
        self.viewModels = viewModels
        self.delegate = delegate
        super.init(parent: parent)
    }
    
    override func start() {
        let controller = DeleteAlertController(
            coordinator: self,
            items: viewModels,
            itemTypeName: buildItemTypeName()
        )
        navigation.present(controller, animated: true)
    }
    
    private func buildItemTypeName() -> DeletableItemViewModelType.ItemTypeName {
        if let item = viewModels.first {
            return type(of: item).typeName
        } else {
            return BaseDeletableItemViewModel.typeName
        }
    }
    
}


// MARK: coordinator delegate protocol
protocol DeleteItemCoordinatorDelegate: AnyObject {
    func didConfirmDeleteItems(_ items: [DeletableItemViewModelType])
}


// MARK: - coordinator methods for DeleteAlertController
extension DeleteItemCoordinator: DeleteAlertControllerCoordinator {
    func didConfirmDeleteItems(_ items: [DeletableItemViewModelType]) {
        delegate?.didConfirmDeleteItems(items)
    }

    func didCloseDeleteAlertController() {
        parent?.removeChild(self)
    }
}
