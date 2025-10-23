import UIKit

final class TaskSectionsListCoordinator: BaseCoordinator {

    private var navigation: UINavigationController
    private weak var viewController: TaskSectionsListViewController?

    init(parent: Coordinator, navigation: UINavigationController) {
        self.navigation = navigation
        super.init(parent: parent)

        self.navigation.delegate = self
    }

    override func start() {
        let vm = TaskSectionsListViewModel(
            coordinator: self,
            sectionEm: DIContainer.shared.resolve(TaskSectionEntityManager.self)!,
            systemSectionsBuilder: DIContainer.shared.resolve(SystemSectionsBuilder.self)!
        )
        let vc = TaskSectionsListViewController(viewModel: vm)

        self.viewController = vc
        navigation.pushViewController(vc, animated: false)
    }
}

// MARK: - TaskSectionsListViewControllerCoordinator

extension TaskSectionsListCoordinator: TaskSectionsListViewControllerCoordinator {

    func startTasksInSectionFlow(_ section: TaskSectionProtocol) {
        switch section {
        case let customSection as CDTaskSectionCustom:
            startTasksInCustomSectionFlow(customSection)

        case _ as TaskSectionSystem:
            print("📋 Открыть системный список")
            // TODO: создать тип для системного списка (там будут другие параметры, скорей всего)
            return

        default:
            print("❌ Ошибка - незивестный тип списка")
        }
    }

    private func startTasksInCustomSectionFlow(_ section: CDTaskSectionCustom) {
        let coordinator = TasksListCoordinator(
            parent: self,
            navigation: navigation,
            section: section
        )

        addChild(coordinator)
        coordinator.start()
    }

    func startDeleteProcessSection(_ sectionVM: TaskSectionDeletableViewModel) {
        let coordinator = DeleteItemCoordinator(
            parent: self,
            navigation: navigation,
            viewModels: [sectionVM],
            delegate: self
        )
        addChild(coordinator)
        coordinator.start()
    }

    func finish() {
        parent?.removeChild(self)
    }
}

// MARK: - UINavigationControllerDelegate

extension TaskSectionsListCoordinator: UINavigationControllerDelegate {
    func navigationController(
        _ navigationController: UINavigationController,
        didShow viewController: UIViewController,
        animated: Bool
    ) {
        guard let fromVC = navigation.transitionCoordinator?.viewController(forKey: .from),
              !navigation.viewControllers.contains(fromVC) else { return }

        if fromVC === self.viewController {
            finish()
        }
    }
}

// MARK: - DeleteItemCoordinatorDelegate

extension TaskSectionsListCoordinator: DeleteItemCoordinatorDelegate {
    func didConfirmDeleteItems(_ items: [DeletableItemViewModelType]) {
        guard let sectionVM = items.first as? TaskSectionDeletableViewModel else {
            return
        }
        //    private var viewModel: TaskSectionsListViewModel
        //        viewModel.deleteCustomSection(sectionViewModel: sectionVM)
    }
}
