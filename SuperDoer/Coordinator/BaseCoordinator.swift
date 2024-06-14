
import Foundation

class BaseCoordinator: Coordinator {
    var childs: [Coordinator] = []
    weak var parent: Coordinator?
    // TODO: перенести сюда navigation (UINavigationController)?
    
    init(parent: Coordinator? = nil) {
        self.parent = parent
    }
    
    func start() {
        fatalError("Child should implement func start")
    }
}
