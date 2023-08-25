
import UIKit

/// Алерт-контроллер выбора места откуда добавлять файл
class AddFileAlertController: UIAlertController {

    let taskViewController: TaskViewController
    
    
    // MARK: init
    init(taskViewController: TaskViewController) {
        self.taskViewController = taskViewController
        
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
    // MARK: life cycle
    override func viewDidLoad() {
        super.viewDidLoad()

        title = "Добавить файл из"
        
        addAction(createImageLibraryAction())
        addAction(createCameraAction())
        addAction(createFilesBrowserAction())
        addAction(createCancelAction())
    }
    
    
    // MARK: methods helpers
    private func createImageLibraryAction() -> UIAlertAction {
        return UIAlertAction(title: "Библиотека изображений", style: .default) { action in
            // TODO: открыть библиотеку изображений
            print("🌇 открыть библиотеку изображений")
        }
    }
    
    private func createCameraAction() -> UIAlertAction {
        return UIAlertAction(title: "Камера", style: .default) { action in
            // TODO: открыть камеру
            print("📸 открыть камеру")
        }
    }
          
    private func createFilesBrowserAction() -> UIAlertAction {
        return UIAlertAction(title: "Файлы", style: .default) { action in
            // TODO: открыть файлы
            print("🗄️ открыть файлы")
        }
    }
    
    private func createCancelAction() -> UIAlertAction {
        return UIAlertAction(title: "Отмена", style: .cancel)
    }
    
}
