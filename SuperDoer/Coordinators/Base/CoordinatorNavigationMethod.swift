import UIKit

enum CoordinatorNavigationMethod {
    case push(to: UINavigationController, animation: Bool)
    case presentModallyWithNav(UINavigationController, from: UIViewController)
    case presentModally(from: UIViewController)
}
