
import UIKit

/// Алерт-контроллер "Удаление задачи"
class TasksDeleteAlertController: UIAlertController {

    private let tasksIndexPath: [IndexPath]
    private let singleTask: Task?
    
    private let actionDelete: UIAlertAction
    private let actionCancel: UIAlertAction
    
    /// - Parameter singleTask : надо передавать только если удаляется одна задача, если удаляется несколько, то параметр будет игнорироваться
    init(tasksIndexPath: [IndexPath], singleTask: Task? = nil, deleteHandler: @escaping (([IndexPath]) -> Void)) {
        self.tasksIndexPath = tasksIndexPath
        self.singleTask = singleTask
        
        actionDelete = UIAlertAction(
            title: tasksIndexPath.count > 1 ? "Удалить задачи" : "Удалить задачу",
            style: .destructive,
            handler: { action in
                deleteHandler(tasksIndexPath)
            }
        )
        
        actionCancel = UIAlertAction(title: "Отмена", style: .cancel)
        
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        title = buildTitle()
        
        addAction(actionDelete)
        addAction(actionCancel)
        
        let impactHeavy = UIImpactFeedbackGenerator(style: .heavy)
        impactHeavy.impactOccurred()
        // TODO: доработать отклик
    }
    
    private func buildTitle() -> String {
        let title = tasksIndexPath.count > 1
        ? "Вы действительно хотите удалить выбранные задачи?"
        : "Задача \"\(singleTask?.title ?? "")\" будет удалена без возможности восстановления"
        
        return title
    }

}
