import UIKit

final class NavigationCoordinator: BaseCoordinator {

    override var rootViewController: UIViewController? { navigation }

    private let navigation: UINavigationController
    private var targetCoordinator: BaseCoordinator?

    init(
        parent: Coordinator,
        navigation: UINavigationController
    ) {
        self.navigation = navigation
        super.init(parent: parent)
    }

    override func startCoordinator() {
        guard let targetCoordinator else {
            ConsoleLogger.warning(
                "targetCoordinator is nil on \(Self.description()) - set before start()"
            )
            return
        }

        startChild(targetCoordinator)
    }

    func setTargetCoordinator(_ coordinator: BaseCoordinator) {
        targetCoordinator = coordinator
    }
}
