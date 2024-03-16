
import UIKit

/// Navigation контроллер, который должен использоваться как
/// контейнер для ViewController'ов открытых модально
class ContainerNavigationController: UINavigationController {

    /// Координатор, который является корневым для цепи контроллеров открытых как модалки
    private weak var coordinator: ContainerNavigationControllerCoordinator?
    
    
    // MARK: init
    init(
        rootViewController: UIViewController, 
        coordinator: ContainerNavigationControllerCoordinator?
    ) {
        self.coordinator = coordinator
        super.init(rootViewController: rootViewController)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
    // MARK: life cycle
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        
        coordinator?.didCloseContainerNavigation()
    }
    
}

// MARK: - coordinator protocol
protocol ContainerNavigationControllerCoordinator: AnyObject {
    /// Будет вызываться всегда, когда цепочка контроллеров, открытых, как модалка закрываются
    /// в том числе, когда они закрываются при тапе вне контроллера
    func didCloseContainerNavigation()
}
