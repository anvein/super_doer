
import UIKit

/// Алерт-контроллер выбора места откуда добавлять файл
class AddFileSourceAlertController: UIAlertController {
    private weak var coordinator: AddFileSourceAlertControllerCoordinator?
    

    // MARK: init
    init(coordinator: AddFileSourceAlertControllerCoordinator) {
        self.coordinator = coordinator
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
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        
        coordinator?.didCloseFileSourceAlertController()
    }
    
    
    // MARK: factory methods
    private func createImageLibraryAction() -> UIAlertAction {
        return UIAlertAction(
            title: "Библиотека изображений",
            style: .default
        ) { [weak self] action in
            self?.coordinator?.didChooseAddFile(fromSource: .library)
        }
    }
    
    private func createCameraAction() -> UIAlertAction {
        return UIAlertAction(
            title: "Камера",
            style: .default
        ) { [weak self] action in
            self?.coordinator?.didChooseAddFile(fromSource: .camera)
        }
    }
          
    private func createFilesBrowserAction() -> UIAlertAction {
        return UIAlertAction(
            title: "Файлы",
            style: .default
        ) { [weak self] action in
            self?.coordinator?.didChooseAddFile(fromSource: .files)
        }
    }
    
    private func createCancelAction() -> UIAlertAction {
        return UIAlertAction(title: "Отмена", style: .cancel)
    }
}


// MARK: - coordinator protocol for AddFileSourceAlertController
protocol AddFileSourceAlertControllerCoordinator: AnyObject {
    /// Выбран вариант "Добавить файл из Галереи"
    func didChooseAddFile(fromSource source: SourceForAddingFile)
    
    /// Вызывается, когда алерт закрыывается (в том числе нажали отмена и другие действия)
    func didCloseFileSourceAlertController()
}
