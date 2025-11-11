import UIKit

extension UINavigationController {
    func pushNavigation(_ viewController: UIViewController, animated: Bool) {
        if viewControllers.count == 0 {
            setViewControllers([viewController], animated: animated)
        } else {
            pushViewController(viewController, animated: animated)
        }
    }
}
