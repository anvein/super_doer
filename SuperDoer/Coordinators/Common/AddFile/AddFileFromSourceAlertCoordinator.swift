import UIKit

typealias SourceForAddingFile = AddFileFromSourceAlertCoordinator.Source

class AddFileFromSourceAlertCoordinator: BaseCoordinator {
    enum Source {
        case library
        case camera
        case files
    }
    
    private var navigation: UINavigationController
    private weak var delegate: AddFileToSourceAlertCoordinatorDelegate?
    
    // MARK: init
    init(
        parent: Coordinator,
        navigation: UINavigationController,
        delegate: AddFileToSourceAlertCoordinatorDelegate
    ) {
        self.navigation = navigation
        self.delegate = delegate
        super.init(parent: parent)
    }
    
    override func start() {
        let alertController = AddFileSourceAlertController(coordinator: self)
        navigation.present(alertController, animated: true)
    }
}


// MARK: delegate protocol
protocol AddFileToSourceAlertCoordinatorDelegate: AnyObject {
    /// Был выбран источник для добавления файла
    func didChooseSourceForAddFile(_ source: SourceForAddingFile)
}


// MARK: coordinator methods for AddFileSourceAlertControllerCoordinator
extension AddFileFromSourceAlertCoordinator: AddFileSourceAlertControllerCoordinator {
    
    func didChooseAddFile(fromSource source: SourceForAddingFile) {
        delegate?.didChooseSourceForAddFile(source)
    }
    
    func didCloseFileSourceAlertController() {
        removeChild(self)
    }
}
