import UIKit
import RxRelay
import RxCocoa

final class TasksListCoordinator: BaseCoordinator {

    private weak var viewController: TasksListViewController?

    private let navigation: UINavigationController
    private let sectionId: UUID?
    private let deleteAlertFactory: DeleteItemsAlertFactory

    private let viewModelEventRelay = PublishRelay<TasksListCoordinatorToVmEvent>()

    init(
        parent: Coordinator,
        navigation: UINavigationController,
        sectionId: UUID?,
        deleteAlertFactory: DeleteItemsAlertFactory
    ) {
        self.navigation = navigation
        self.sectionId = sectionId
        self.deleteAlertFactory = deleteAlertFactory
        super.init(parent: parent)
        self.navigation.delegate = self
    }

    override func start() {
        super.start()

        let vm = TasksListViewModel(
            coordinator: self,
            repository: DIContainer.container.resolve(TasksListRepository.self, argument: sectionId)!,
            sectionCDManager: DIContainer.container.resolve(TaskSectionCoreDataManager.self)!
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
        // TODO: не срабатывает если перейти на деталку а потом назад в список задач -> список разделов
        // потому что каждый координатор при создании устанавливает себя в navigation.delegate (а это один navigation)
        guard let selfVC = self.viewController else { return }
        finishIfNavigationPop(selfVC, from: navigation)
    }
}
