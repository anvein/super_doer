import UIKit

protocol Coordinator: AnyObject {

    var childs: [Coordinator] { get set }
    var parent: Coordinator? { get set }
    var rootViewController: UIViewController { get }

    func start/*<RootController>*/(
        onPresent: (_ coordinatorRootVC: UIViewController) -> Void
    ) /*where RootController: UIViewController*/
    func setup()
    func navigate() 
    func finish()
}

extension Coordinator {
    func addChild(_ coordinator: Coordinator) {
        childs.append(coordinator)
    }
    
    func removeChild(_ coordinator: Coordinator) {
        childs = childs.filter {
            return $0 !== coordinator
        }
    }
    
    func removeChild(withType deletedChildType: Coordinator.Type) {
        childs = childs.filter { coordinator in
            return type(of: coordinator) != deletedChildType
        }
    }
}
