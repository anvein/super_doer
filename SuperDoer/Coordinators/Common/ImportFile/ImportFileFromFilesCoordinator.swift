import UIKit

class ImportFileFromFilesCoordinator: BaseCoordinator {
    
    private var navigation: UINavigationController
    private weak var delegate: ImportFileFromFilesCoordinatorDelegate?
    
    init(
        parent: Coordinator,
        navigation: UINavigationController,
        delegate: ImportFileFromFilesCoordinatorDelegate
    ) {
        self.navigation = navigation
        self.delegate = delegate
        super.init(parent: parent)
    }
    
    override func start() {
        let documentPicker = UIDocumentPickerViewController(
            forOpeningContentTypes: [.jpeg, .pdf, .text]
        )
        documentPicker.delegate = self
        documentPicker.allowsMultipleSelection = false

        navigation.present(documentPicker, animated: true)
    }
}

// MARK: - coordinator delegate protocol
protocol ImportFileFromFilesCoordinatorDelegate: AnyObject {
    func didFinishPickingFileFromLibrary(withUrl url: URL)
}


// MARK: - UIDocumentPickerDelegate
extension ImportFileFromFilesCoordinator: UIDocumentPickerDelegate {
    func documentPicker(
        _ controller: UIDocumentPickerViewController,
        didPickDocumentsAt urls: [URL]
    ) {
        controller.dismiss(animated: true)
        
        for url in urls {
            delegate?.didFinishPickingFileFromLibrary(withUrl: url)
            break
        }
        finish()
    }
    
    // срабатывает даже при закрытии свайпом вниз
    func documentPickerWasCancelled(_ controller: UIDocumentPickerViewController) {
        finish()
    }
}
