
import UIKit

final class AppCoordinator: BaseCoordinator {
    
    private var window: UIWindow
    
    private var navigation: UINavigationController = {
        let naviController = UINavigationController()
        
        return naviController
    }()
    
    init(window: UIWindow) {
        self.window = window
        super.init(parent: nil)
    }
    
    override func start() {
        configWindow()
        let taskSectionListCoordinator = TaskSectionListCoordinator(
            parent: self, 
            navigation: navigation
        )
        
        addChild(taskSectionListCoordinator)
        taskSectionListCoordinator.start()
    }
    
    private func configWindow() {
        window.rootViewController = navigation
        window.makeKeyAndVisible()
    }
}
