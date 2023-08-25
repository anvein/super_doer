
import UIKit

/// Алерт-контроллер удаления файла
class FileDeleteAlertController: UIAlertController {

    private let actionDelete: UIAlertAction
    private let actionCancel: UIAlertAction
    
    /// - Parameter fileIndexPath: IndexPath строки файла, который удаляется
    /// - Parameter fileDeleteHandler: замыкание, которое должно удалять данные из дата-сорса и из таблицы
    init(fileIndexPath: IndexPath, fileDeleteHandler deleteHandler: @escaping (IndexPath) -> Void) {
        actionDelete = UIAlertAction(
            title: "Удалить файл",
            style: .destructive,
            handler: { action in
                deleteHandler(fileIndexPath)
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
        
        title = "Вы действительно хотите удалить этот файл?"
        
        addAction(actionDelete)
        addAction(actionCancel)
        
        impactOcurred()
    }

    private func impactOcurred() {
        let impactHeavy = UIImpactFeedbackGenerator(style: .heavy)
        impactHeavy.impactOccurred()
        // TODO: доработать отклик
    }
}
