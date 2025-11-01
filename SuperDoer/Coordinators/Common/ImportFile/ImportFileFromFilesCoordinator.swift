import UIKit
import RxCocoa
import RxRelay
import RxSwift

class ImportFileFromFilesCoordinator: BaseCoordinator {
    let disposeBag = DisposeBag()

    private var parentController: UIViewController

    private let finishResultRelay = PublishRelay<URL?>()
    var finishResult: Signal<URL?> { finishResultRelay.asSignal() }

    init(parent: Coordinator, parentController: UIViewController) {
        self.parentController = parentController
        super.init(parent: parent)
    }
    
    override func start() {
        super.start()

        let documentPicker = UIDocumentPickerViewController(
            forOpeningContentTypes: [.jpeg, .pdf, .text, .gif]
        )
        documentPicker.delegate = self
        documentPicker.allowsMultipleSelection = false

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

        controller.dismiss(animated: true)
        finishResultRelay.accept(resultFileUrl)
        finish()
    }
    
    // срабатывает даже при закрытии свайпом вниз
    func documentPickerWasCancelled(_ controller: UIDocumentPickerViewController) {
        finishResultRelay.accept(nil)
        finish()
    }
}
