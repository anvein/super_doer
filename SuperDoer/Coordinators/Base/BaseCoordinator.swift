import Foundation
import UIKit

class BaseCoordinator: NSObject, Coordinator {
    var childs: [Coordinator] = []
    weak var parent: Coordinator?
    
    init(parent: Coordinator? = nil) {
        self.parent = parent
    }
    
    func start() {
        fatalError("Child should implement func start")
    }

    func finish() {
        parent?.removeChild(self)
    }

    func finishIfNavigationPop(_ vc: UIViewController, from navigation: UINavigationController) {
        print("### FRM \(navigation.transitionCoordinator?.viewController(forKey: .from)?.description)")
        guard let fromVC = navigation.transitionCoordinator?.viewController(forKey: .from),
              !navigation.viewControllers.contains(fromVC) else { return }

        if fromVC === vc {
            finish()
            print("### FINISH \(Self.description())")
        }
    }
}
