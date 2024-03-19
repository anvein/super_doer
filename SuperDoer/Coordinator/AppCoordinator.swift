
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
        configWindow()
        
        let viewModel = TaskSectionListViewModel(
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
    
    private func configWindow() {
        window.rootViewController = navigation
        window.makeKeyAndVisible()
    }
    
    
    private func buildSectionsViewModel() -> TaskSectionListViewModel.Sections {
        var sections: [[TaskSectionProtocol]] = [[], []]
        
        sections[TaskSectionListViewModel.systemSectionsId] = systemSectionsBuilder.buildSections()
        sections[TaskSectionListViewModel.customSectionsId] = sectionEm.getCustomSectionsWithOrder()
        
        return sections
    }
}
