import UIKit

enum CoordinatorNavigationMethod {
    case push(to: UINavigationController, animation: Bool)
    case presentWithNavigation(from: UIViewController)
    case presentWithoutNavigation(from: UIViewController)
}
