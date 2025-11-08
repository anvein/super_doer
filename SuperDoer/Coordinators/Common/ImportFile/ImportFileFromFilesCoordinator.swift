import UIKit
import RxCocoa
import RxRelay
import RxSwift

final class ImportFileFromFilesCoordinator: BaseCoordinator {
    private var parentController: UIViewController

    override var rootViewController: UIViewController? { viewController }
    private var viewController: UIDocumentPickerViewController?

    private let finishResultRelay = PublishRelay<URL?>()
    var finishResult: Signal<URL?> { finishResultRelay.asSignal() }

    override var isAutoFinishEnabled: Bool { false }

    init(parent: Coordinator, parentController: UIViewController) {
        self.parentController = parentController
        super.init(parent: parent)
    }
    
    override func startCoordinator() {
        let documentPicker = UIDocumentPickerViewController(
            forOpeningContentTypes: [.jpeg, .pdf, .text, .gif]
        )
        documentPicker.delegate = self
        documentPicker.allowsMultipleSelection = false

        viewController = documentPicker

        parentController.present(documentPicker, animated: true)
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
