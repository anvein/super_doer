import UIKit

extension UINavigationController {
    func pushNavigation(_ viewController: UIViewController, animated: Bool) {
        if viewControllers.isEmpty {
            setViewControllers([viewController], animated: animated)
        } else {
            pushViewController(viewController, animated: animated)
        }
    }
}
