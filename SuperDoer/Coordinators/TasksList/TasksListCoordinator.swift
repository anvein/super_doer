import UIKit
import RxRelay
import RxCocoa

final class TasksListCoordinator: BaseCoordinator {

    private weak var viewController: TasksListViewController?

    private let navigation: UINavigationController
    private let section: CDTaskCustomSection // TODO: переделать на передачу ID
    private let deleteAlertFactory: DeleteItemsAlertFactory

    private let viewModelEventRelay = PublishRelay<TasksListCoordinatorToVmEvent>()

    init(
        parent: Coordinator,
        navigation: UINavigationController,
        section: CDTaskCustomSection,
        deleteAlertFactory: DeleteItemsAlertFactory
    ) {
        self.navigation = navigation
        self.section = section
        self.deleteAlertFactory = deleteAlertFactory
        super.init(parent: parent)
        self.navigation.delegate = self
    }

    override func start() {
        let vm = TasksListViewModel(
            coordinator: self,
            repository: TasksListRepository(
                taskSection: section,
                taskCDManager: DIContainer.container.resolve(TaskCoreDataManager.self)!
            ),
            sectionCDManager: DIContainer.container.resolve(TaskSectionEntityManager.self)!
        )
        let vc = TasksListViewController(viewModel: vm)

        self.viewController = vc
        navigation.pushViewController(vc, animated: true)
    }

}

// MARK: - TasksListCoordinatorType

extension TasksListCoordinator: TasksListCoordinatorType {
    var viewModelEventSignal: Signal<TasksListCoordinatorToVmEvent> {
        viewModelEventRelay.asSignal()
    }

    func startTaskDetailFlow(for taskId: UUID) {
        let coordinator = TaskDetailCoordinator(
            parent: self,
            navigation: navigation,
            taskId: taskId
        )
        addChild(coordinator)
        coordinator.start()
    }

    func startDeleteTasksConfirmation(for items: [(TasksListItemEntity, IndexPath)]) {
        let deletableTasksVMs = items.map {
            TaskDeletableViewModel(task: $0.0, indexPath: $0.1)
        }

        let alert = deleteAlertFactory.makeAlert(deletableTasksVMs) { [weak self] deletableVM in
            guard let deletableVM = deletableVM as? [TaskDeletableViewModel] else { return }

            self?.viewModelEventRelay.accept(
                .onDeleteTasksConfirmed(deletableVM)
            )
        } onCancel: { [weak self] in
            self?.viewModelEventRelay.accept(.onDeleteTasksCanceled)
        }

        navigation.present(alert, animated: true)
    }
}

// MARK: - UINavigationControllerDelegate

extension TasksListCoordinator: UINavigationControllerDelegate {
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
