import Foundation
import UIKit

class BaseCoordinator: NSObject, Coordinator {
    var childs: [Coordinator] = []
    weak var parent: Coordinator?
    
    init(parent: Coordinator? = nil) {
        self.parent = parent
    }
    
    func start() {
#if DEBUG
        print("### START coordinator: \(self.description)")
#endif
    }

    func finish() {
        parent?.removeChild(self)

#if DEBUG
        print("### FINISH coordinator: \(self.description)")
#endif
    }

    func finishIfNavigationPop(_ vc: UIViewController, from navigation: UINavigationController) {
        guard let fromVC = navigation.transitionCoordinator?.viewController(forKey: .from),
              !navigation.viewControllers.contains(fromVC) else { return }

        if fromVC === vc {
            finish()
        }
    }
}
