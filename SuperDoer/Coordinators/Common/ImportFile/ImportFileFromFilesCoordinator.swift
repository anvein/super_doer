import UIKit
import UniformTypeIdentifiers
import RxCocoa
import RxRelay
import RxSwift

final class ImportFileFromFilesCoordinator: BaseCoordinator {

    private let pickerController: UIDocumentPickerViewController
    override var rootViewController: UIViewController { pickerController }

    private let finishResultRelay = PublishRelay<URL?>()
    var finishResult: Signal<URL?> { finishResultRelay.asSignal() }

    override var isAutoFinishEnabled: Bool { false }

    init(parent: Coordinator, types: [UTType]) {
        self.pickerController = UIDocumentPickerViewController(forOpeningContentTypes: types)
        super.init(parent: parent)
    }

    override func setup() {
        super.setup()
        pickerController.allowsMultipleSelection = false
        pickerController.delegate = self
    }

}

// MARK: - UIDocumentPickerDelegate

extension ImportFileFromFilesCoordinator: UIDocumentPickerDelegate {
    func documentPicker(
        _ controller: UIDocumentPickerViewController,
        didPickDocumentsAt urls: [URL]
    ) {
        var resultFileUrl: URL?
        for url in urls {
            resultFileUrl = url
            break
        }

        finishResultRelay.accept(resultFileUrl)
        controller.dismiss(animated: true) { [weak self] in
            self?.finish()
        }
    }
    
    // срабатывает даже при закрытии свайпом вниз
    func documentPickerWasCancelled(_ controller: UIDocumentPickerViewController) {
        finishResultRelay.accept(nil)
        finish()
    }
}
