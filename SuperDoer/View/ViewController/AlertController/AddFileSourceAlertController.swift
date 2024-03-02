
import UIKit

/// Алерт-контроллер выбора места откуда добавлять файл
class AddFileSourceAlertController: UIAlertController {
    weak var delegate: AddFileSourceAlertControllerDelegate?
    
    
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
            self.delegate?.didChooseAddFileFromImageLibrary()
        }
    }
    
    private func createCameraAction() -> UIAlertAction {
        return UIAlertAction(title: "Камера", style: .default) { action in
            self.delegate?.didChooseAddFileFromCamera()
        }
    }
          
    private func createFilesBrowserAction() -> UIAlertAction {
        return UIAlertAction(title: "Файлы", style: .default) { action in
            self.delegate?.didChooseAddFileFromFiles()
        }
    }
    
    private func createCancelAction() -> UIAlertAction {
        return UIAlertAction(title: "Отмена", style: .cancel)
    }
    
}


// MARK: delegate
protocol AddFileSourceAlertControllerDelegate: AnyObject {
    func didChooseAddFileFromImageLibrary()
    
    func didChooseAddFileFromCamera()
    
    func didChooseAddFileFromFiles()
}
