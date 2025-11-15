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

    private var mode: Mode

    override var rootViewController: UIViewController { pickerController }
    private let pickerController = UIImagePickerController()

    private let finishResultRelay = PublishRelay<ImageDataResult?>()
    var finishResult: Signal<ImageDataResult?> { finishResultRelay.asSignal() }

    init(parent: Coordinator, mode: Mode) {
        self.mode = mode
        super.init(parent: parent)
    }

    override func setup() {
        super.setup()

        // TODO: сделать нормальные проверки
        guard UIImagePickerController.isSourceTypeAvailable(mode.asSourceType) == true else {
            print("❌ Нет доступа к \(mode.title)")
            // TODO: вернуть как finishResult
            return
        }

        let availableTypes = UIImagePickerController.availableMediaTypes(for: mode.asSourceType)
        guard (availableTypes?.count ?? 0) > 0 else {
            print("❌ нет доступных форматов в \(mode.title)")
            // TODO: вернуть как finishResult
            return
        }

        pickerController.delegate = self
        pickerController.presentationController?.delegate = self
        pickerController.mediaTypes = availableTypes ?? []

        if mode == .camera {
            pickerController.sourceType = .camera
        }
    }

}

// MARK: - UIImagePickerControllerDelegate & UINavigationControllerDelegate

extension ImportImageFromLibraryCoordinator: UIImagePickerControllerDelegate, UINavigationControllerDelegate {

    func imagePickerController(
        _ picker: UIImagePickerController,
        didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey: Any]
    ) {
        let originalImage = info[.originalImage] as? UIImage
        let imageData = originalImage?.jpegData(compressionQuality: 1)

        finishResultRelay.accept(imageData)
        picker.dismiss(animated: true)
    }

    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        finishResultRelay.accept(nil)
        picker.dismiss(animated: true)
    }
}

// отследить у UIImagePickerController didDisappear не получилось т.к.:
// его нельзя наследовать и переопределять
// didDismissImagePickerController срабатывает только когда пользователь нажимает на кнопку отмена
// если же пользователь свайпом вниз (или как-то по другому) закроет UIImagePickerController, то didDismissImagePickerController не срабатывает
// но помог делегат presentationController'а
// p.s.: эта функция тоже срабатывает не всегда на каких-то iOS (разобраться)
extension ImportImageFromLibraryCoordinator: UIAdaptivePresentationControllerDelegate {
    func presentationControllerDidDismiss(_ presentationController: UIPresentationController) {
        // finish() вызовется сам
    }
}
