import UIKit
import RxRelay
import RxCocoa
import RxSwift

final class TasksListCoordinator: BaseCoordinator {

    private let disposeBag = DisposeBag()

    private weak var viewController: TasksListViewController?
    private weak var viewModel: (TasksListNavigationEmittable & TasksListCoordinatorResultHandler)?

    private let navigation: UINavigationController
    private let sectionId: UUID?
    private let deleteAlertFactory: DeleteItemsAlertFactory

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
            repository: DIContainer.container.resolve(TasksListRepository.self, argument: sectionId)!,
            sectionCDManager: DIContainer.container.resolve(TaskSectionCoreDataManager.self)!
        )
        let vc = TasksListViewController(viewModel: vm)

        vm.navigationEvent.emit(onNext: { [weak self] event in
            self?.handleNavigationEvent(event)
        })
        .disposed(by: disposeBag)

        self.viewController = vc
        self.viewModel = vm

        navigation.pushViewController(vc, animated: true)
    }

    private func handleNavigationEvent(_ event: TasksListNavigationEvent) {
        switch event {
        case .openTaskDetail(let taskId):
            startTaskDetailFlow(for: taskId)

        case .openDeleteTasksConfirmation(let deletableTasksViewModels):
            startDeleteTasksConfirmation(for: deletableTasksViewModels)
        }
    }

    // MARK: - Start childs

    private func startTaskDetailFlow(for taskId: UUID) {
        let coordinator = TaskDetailCoordinator(
            parent: self,
            navigation: navigation,
            taskId: taskId
        )
        addChild(coordinator)
        coordinator.start()
    }

    private func startDeleteTasksConfirmation(for deletableTasksVMs: [TaskDeletableViewModel]) {
        let alert = deleteAlertFactory.makeAlert(deletableTasksVMs) { [weak self] deletableVM in
            guard let deletableVM = deletableVM as? [TaskDeletableViewModel] else { return }

            self?.viewModel?.coordinatorResult.accept(
                .onDeleteTasksConfirmed(deletableVM)
            )
        } onCancel: { [weak self] in
            self?.viewModel?.coordinatorResult.accept(.onDeleteTasksCanceled)
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
