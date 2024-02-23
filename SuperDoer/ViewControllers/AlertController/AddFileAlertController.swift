
import UIKit

/// Алерт-контроллер выбора места откуда добавлять файл
class AddFileAlertController: UIAlertController {
    
    let taskViewController: TaskDetailViewController
    
    
    // MARK: init
    init(controller: TaskDetailViewController) {
        self.taskViewController = controller
        
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
            // TODO: сделать нормальные проверки
            guard UIImagePickerController.isSourceTypeAvailable(.photoLibrary) == true else {
                print("❌ Нет доступа к галерее")
                return
            }
            
            let availableMediaTypes = UIImagePickerController.availableMediaTypes(for: .photoLibrary)
            guard (availableMediaTypes?.count ?? 0) > 0 else {
                print("❌ нет доступных форматов в галерее")
                return
            }
            
            let imagePickerController = UIImagePickerController()
            imagePickerController.delegate = self.taskViewController
            imagePickerController.mediaTypes = availableMediaTypes ?? []
            self.taskViewController.present(imagePickerController, animated: true)
        }
    }
    
    private func createCameraAction() -> UIAlertAction {
        return UIAlertAction(title: "Камера", style: .default) { action in
            guard UIImagePickerController.isSourceTypeAvailable(.camera) == true else {
                print("❌ Нет доступа к камере")
                return
            }
            
            let availableMediaTypes = UIImagePickerController.availableMediaTypes(for: .camera)
            guard (availableMediaTypes?.count ?? 0) > 0 else {
                print("❌ нет доступных форматов у камеры")
                return
            }
            
            let imagePickerController = UIImagePickerController()
            imagePickerController.sourceType = .camera
            imagePickerController.delegate = self.taskViewController
            imagePickerController.mediaTypes = availableMediaTypes ?? []
            self.taskViewController.present(imagePickerController, animated: true)
        }
    }
          
    private func createFilesBrowserAction() -> UIAlertAction {
        return UIAlertAction(title: "Файлы", style: .default) { action in
            let documentPicker = UIDocumentPickerViewController(forOpeningContentTypes: [.jpeg, .pdf, .text])
            documentPicker.delegate = self.taskViewController
            documentPicker.allowsMultipleSelection = false
            
            self.taskViewController.present(documentPicker, animated: true)
        }
    }
    
    private func createCancelAction() -> UIAlertAction {
        return UIAlertAction(title: "Отмена", style: .cancel)
    }
    
}


