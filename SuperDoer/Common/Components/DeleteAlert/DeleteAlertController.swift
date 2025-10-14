
import UIKit

/// Алерт-контроллер "Удаление элемента"
class DeleteAlertController: UIAlertController {
    
    private typealias Actions = (
        deleteAction: UIAlertAction,
        cancelAction: UIAlertAction
    )
    
    private weak var coordinator: DeleteAlertControllerCoordinator?
    
    /// Массив с элементами, которые надо удалить
    private let items: [DeletableItemViewModelType]
    private let itemTypeName: DeletableItemViewModelType.ItemTypeName
    
    // MARK: init
    init(
        coordinator: DeleteAlertControllerCoordinator,
        items: [DeletableItemViewModelType],
        itemTypeName: DeletableItemViewModelType.ItemTypeName
    ) {
        self.coordinator = coordinator
        self.items = items
        self.itemTypeName = itemTypeName
    
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: life cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        title = buildTitle()
            
        let actions = buildActions()
        addAction(actions.deleteAction)
        addAction(actions.cancelAction)
    
        runImpact()
    }
    
    // MARK: other methods
    private func buildTitle() -> String {
        var result: String
        if items.count == 1, let item = items.first  {
            let resultItemTitle = "\"\(item.title)\" "
            
            result = "\(itemTypeName.oneIP.firstLetterCapitalized) \(resultItemTitle)будет удален(а) без возможности восстановления"
        } else {
            result = "Вы действительно хотите удалить выбранные \(itemTypeName.manyVP)?"
        }
        
        return result
    }
    
    private func buildDeleteActionTitle() -> String {
        let typeName = (items.count == 1) ? itemTypeName.oneVP: itemTypeName.manyVP
        return "Удалить \(typeName)"
    }
    
    private func buildActions() -> Actions {
        let deleteAction = UIAlertAction(
            title: buildDeleteActionTitle(),
            style: .destructive) { [weak self] _ in
                guard let items = self?.items else { return }
                self?.coordinator?.didConfirmDeleteItems(items)
            }
        
        
        let cancelAction = UIAlertAction(
            title: "Отмена",
            style: .cancel,
            handler: { [weak self] _ in
                self?.coordinator?.didCloseDeleteAlertController()
            }
        )
        
        return (
            deleteAction: deleteAction,
            cancelAction: cancelAction
        )
    }
    
    private func runImpact() {
        let impactHeavy = UIImpactFeedbackGenerator(style: .heavy)
        impactHeavy.impactOccurred()
    }

    
    
}


// MARK: - coordinator protocol for DeleteAlertController
protocol DeleteAlertControllerCoordinator: AnyObject {
    /// Была нажата кнопка подтверждения удаления
    func didConfirmDeleteItems(_ items: [DeletableItemViewModelType])
    
    /// Алерт был закрыт без выбора действия
    func didCloseDeleteAlertController()
}
