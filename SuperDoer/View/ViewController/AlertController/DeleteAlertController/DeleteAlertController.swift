
import UIKit

/// Алерт-контроллер "Удаление элемента"
class DeleteAlertController: UIAlertController {
    typealias ItemTypeName = (oneIP: String, oneVP: String, manyIP: String)
    
    /// Массив с IndexPath элементов, которые надо удалить
    private let itemsIndexPaths: [IndexPath]
    private let singleItem: DeletableItem? // TODO: проработать получение названия элемента
    
    /// oneIP - именительный падеж, ед.ч.
    /// oneVP - винительный падеж, ед. ч;
    var itemTypeName: ItemTypeName = ItemTypeName(oneIP: "элемент", oneVP: "элемент", manyIP: "элементы")
    
    private let deleteHandler: (([IndexPath]) -> Void)
    
    /// - Parameter singleTask : надо передавать только если удаляется одна задача, если удаляется несколько, то параметр будет игнорироваться
    init(
        itemsIndexPath: [IndexPath],
        singleItem: DeletableItem? = nil,
        deleteHandler: @escaping (([IndexPath]) -> Void)
    ) {
        self.itemsIndexPaths = itemsIndexPath
        self.singleItem = singleItem
        self.deleteHandler = deleteHandler
    
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let actions = buildActions()
    
        title = buildTitle()
        
        addAction(actions.deleteAction)
        addAction(actions.cancelAction)
        
        runImpact()
    }
    
    private func buildTitle() -> String {
        var result: String
        if itemsIndexPaths.count == 1 {
            var resultItemTitle = ""
            if let singleItemTitle = singleItem?.title {
                resultItemTitle = "\"\(singleItemTitle))\" "
            }
            
            result = "\(itemTypeName.oneIP.firstLetterCapitalized) \(resultItemTitle)будет удалена без возможности восстановления"
        } else {
            result = "Вы действительно хотите удалить выбранные \(itemTypeName.manyIP)?"
        }
        
        return result
    }
    
    private func buildActions() -> (deleteAction: UIAlertAction, cancelAction: UIAlertAction) {
        
        let deleteAction = UIAlertAction(
            title: "Удалить \(itemsIndexPaths.count == 1 ? itemTypeName.oneVP : itemTypeName.manyIP)",
            style: .destructive,
            handler: { [unowned self] action in
                self.deleteHandler(self.itemsIndexPaths)
            }
        )
        
        let cancelAction = UIAlertAction(title: "Отмена", style: .cancel)
        
        return (
            deleteAction: deleteAction,
            cancelAction: cancelAction
        )
    }
    
    private func runImpact() {
        // TODO: доработать отклик
        let impactHeavy = UIImpactFeedbackGenerator(style: .heavy)
        impactHeavy.impactOccurred()
    }

}
