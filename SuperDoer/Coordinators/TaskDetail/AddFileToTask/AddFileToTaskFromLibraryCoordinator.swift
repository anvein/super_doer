
import UIKit

///  Координатор работает для загрузки файлов из:
///  - Галереи
///  - Камеры
class AddFileToTaskFromLibraryCoordinator: NSObject, Coordinator {
    enum Mode {
        case camera
        case library
        
        var asSourceType: UIImagePickerController.SourceType {
            switch self {
            case .camera:
                return .camera
            case .library:
                return .photoLibrary
            }
        }
        
        var title: String {
            switch self {
            case .camera:
                return "камере"
            case .library:
                return "галерее"
            }
        }
    }
    
    var childs: [Coordinator] = []
    weak var parent: Coordinator?
    
    private var navigation: UINavigationController
    private weak var delegate: AddFileToTaskFromLibraryCoordinatorDelegate?

    private var mode: Mode
    
    init(
        parent: Coordinator,
        navigation: UINavigationController,
        delegate: AddFileToTaskFromLibraryCoordinatorDelegate,
        mode: Mode
    ) {
        self.navigation = navigation
        self.delegate = delegate
        self.parent = parent
        self.mode = mode
    }
    
    func start() {
        // TODO: сделать нормальные проверки
        guard UIImagePickerController.isSourceTypeAvailable(mode.asSourceType) == true else {
            print("❌ Нет доступа к \(mode.title)")
            return
        }
        
        let availableTypes = UIImagePickerController.availableMediaTypes(for: mode.asSourceType)
        guard (availableTypes?.count ?? 0) > 0 else {
            print("❌ нет доступных форматов в \(mode.title)")
            return
        }
        
        let controller = UIImagePickerController()
        controller.delegate = self
        controller.presentationController?.delegate = self
        controller.mediaTypes = availableTypes ?? []
        
        if mode == .camera {
            controller.sourceType = .camera
        }
        
        navigation.present(controller, animated: true)
    }
}


// MARK: - coordinator delegate protocol
protocol AddFileToTaskFromLibraryCoordinatorDelegate: AnyObject {
    func didFinishPickingMediaFromLibrary(imageData: NSData)
}


// MARK: - UIImagePicker
extension AddFileToTaskFromLibraryCoordinator: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    func imagePickerController(
        _ picker: UIImagePickerController,
        didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]
    ) {
        picker.dismiss(animated: true)
        guard let originalImage = info[.originalImage] as? UIImage else {
            return
        }
        
        let imgData = NSData(data: originalImage.jpegData(compressionQuality: 1)!)
        
        delegate?.didFinishPickingMediaFromLibrary(imageData: imgData)
        parent?.removeChild(self)
    }
    
    // не срабатывает если закрыть контроллер свайпом вниз
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        parent?.removeChild(self)
    }
}

// отследить у UIImagePickerController didDisappear не получилось т.к.:
// его нельзя наследовать и переопределять
// didDismissImagePickerController срабатывает только когда пользователь нажимает на кнопку отмена
// если же пользователь свайпом вниз (или как-то по другому) закроет UIImagePickerController, то didDismissImagePickerController не срабатывает
// но помог делегат presentationController'а
// TODO: эта функция тоже срабатывает не всегда (разобраться)
extension AddFileToTaskFromLibraryCoordinator: UIAdaptivePresentationControllerDelegate {
    func presentationControllerDidDismiss(_ presentationController: UIPresentationController) {
        parent?.removeChild(self)
    }
}
