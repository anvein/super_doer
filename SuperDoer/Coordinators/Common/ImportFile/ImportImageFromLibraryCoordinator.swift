import UIKit
import RxCocoa
import RxRelay
import RxSwift

///  Координатор работает для загрузки файлов из:
///  - Галереи
///  - Камеры
class ImportImageFromLibraryCoordinator: BaseCoordinator {
    typealias ImageDataResult = Data

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
            case .camera:  "камере"
            case .library: "галерее"
            }
        }
    }

    let disposeBag = DisposeBag()

    private var navigation: UINavigationController
    private var mode: Mode

    private let finishResultRelay = PublishRelay<ImageDataResult?>()
    var finishResult: Signal<ImageDataResult?> { finishResultRelay.asSignal() }

    init(
        parent: Coordinator,
        navigation: UINavigationController,
        mode: Mode
    ) {
        self.navigation = navigation
        self.mode = mode
        super.init(parent: parent)
    }
    
    override func start() {
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

// MARK: - UIImagePickerControllerDelegate & UINavigationControllerDelegate

extension ImportImageFromLibraryCoordinator: UIImagePickerControllerDelegate, UINavigationControllerDelegate {

    func imagePickerController(
        _ picker: UIImagePickerController,
        didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]
    ) {
        let originalImage = info[.originalImage] as? UIImage
        let imageData = originalImage?.jpegData(compressionQuality: 1)

        finishResultRelay.accept(imageData)

        picker.dismiss(animated: true)
        finish()
    }

    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        finishResultRelay.accept(nil)

        picker.dismiss(animated: true)
        finish()
    }
}

// отследить у UIImagePickerController didDisappear не получилось т.к.:
// его нельзя наследовать и переопределять
// didDismissImagePickerController срабатывает только когда пользователь нажимает на кнопку отмена
// если же пользователь свайпом вниз (или как-то по другому) закроет UIImagePickerController, то didDismissImagePickerController не срабатывает
// но помог делегат presentationController'а
// TODO: эта функция тоже срабатывает не всегда на каких-то iOS (разобраться)
extension ImportImageFromLibraryCoordinator: UIAdaptivePresentationControllerDelegate {
    func presentationControllerDidDismiss(_ presentationController: UIPresentationController) {
        finish()
    }
}
