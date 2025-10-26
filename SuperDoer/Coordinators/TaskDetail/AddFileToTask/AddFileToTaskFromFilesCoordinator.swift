import UIKit

class AddFileToTaskFromFilesCoordinator: NSObject, Coordinator {
    var childs: [Coordinator] = []
    weak var parent: Coordinator?
    
    private var navigation: UINavigationController
    private weak var delegate: AddFileToTaskFromFilesCoordinatorDelegate?

    
    init(
        parent: Coordinator,
        navigation: UINavigationController,
        delegate: AddFileToTaskFromFilesCoordinatorDelegate
    ) {
        self.navigation = navigation
        self.delegate = delegate
        self.parent = parent
    }
    
    func start() {
        let documentPicker = UIDocumentPickerViewController(
            forOpeningContentTypes: [.jpeg, .pdf, .text]
        )
        documentPicker.delegate = self
        documentPicker.allowsMultipleSelection = false

        navigation.present(documentPicker, animated: true)
    }

    func finish() {
        parent?.removeChild(self)
    }
}


// MARK: - coordinator delegate protocol
protocol AddFileToTaskFromFilesCoordinatorDelegate: AnyObject {
    func didFinishPickingFileFromLibrary(withUrl url: URL)
}


// MARK: - UIDocumentPickerDelegate
extension AddFileToTaskFromFilesCoordinator: UIDocumentPickerDelegate {
    func documentPicker(
        _ controller: UIDocumentPickerViewController,
        didPickDocumentsAt urls: [URL]
    ) {
        controller.dismiss(animated: true)
        
        for url in urls {
            delegate?.didFinishPickingFileFromLibrary(withUrl: url)
            break
        }
        parent?.removeChild(self)
    }
    
    // срабатывает даже при закрытии свайпом вниз
    func documentPickerWasCancelled(_ controller: UIDocumentPickerViewController) {
        parent?.removeChild(self)
    }
}
