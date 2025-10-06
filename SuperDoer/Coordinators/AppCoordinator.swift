
import UIKit

final class AppCoordinator: BaseCoordinator {
    
    private var window: UIWindow
    
    private var sectionEm: TaskSectionEntityManager
    private var systemSectionsBuilder: SystemSectionsBuilder
    
    private var navigation: UINavigationController = {
        let naviController = UINavigationController()
        
        return naviController
    }()
    
    init(
        window: UIWindow,
        sectionEm: TaskSectionEntityManager,
        systemSectionsBuilder: SystemSectionsBuilder
    ) {
        self.window = window
        self.sectionEm = sectionEm
        self.systemSectionsBuilder = systemSectionsBuilder
        super.init(parent: nil)
    }
    
    override func start() {
        configureWindow()
        
        let viewModel = TaskSectionsListViewModel(
            sectionEm: sectionEm,
            sections: buildSectionsViewModel()
        )
        let taskSectionListCoordinator = TaskSectionListCoordinator(
            parent: self, 
            navigation: navigation,
            viewModel: viewModel
        )
        
        addChild(taskSectionListCoordinator)
        taskSectionListCoordinator.start()
    }
    
    private func configureWindow() {
        window.rootViewController = navigation
        window.makeKeyAndVisible()
    }
    
    
    private func buildSectionsViewModel() -> TaskSectionsListViewModel.SectionGroup {
        var sections: [[TaskSectionProtocol]] = [[], []]
        
        sections[TaskSectionsListViewModel.systemSectionsId] = systemSectionsBuilder.buildSections()
        sections[TaskSectionsListViewModel.customSectionsId] = sectionEm.getCustomSectionsWithOrder()
        
        return sections
    }
}
