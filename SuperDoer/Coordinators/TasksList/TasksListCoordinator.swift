import UIKit
import RxRelay
import RxCocoa
import RxSwift

final class TasksListCoordinator: BaseCoordinator {

    private let navigation: UINavigationController
    private let sectionId: UUID?
    private let deleteAlertFactory: DeleteItemsAlertFactory

    private var viewController: TasksListViewController?
    private var viewModel: (TasksListNavigationEmittable & TasksListCoordinatorResultHandler)?

    override var rootViewController: UIViewController? { viewController }

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
    }

    override func startCoordinator() {
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
            taskId: taskId,
            deleteAlertFactory: DIContainer.container.resolve(DeleteItemsAlertFactory.self)!
        )
        startChild(coordinator)
    }

    private func startDeleteTasksConfirmation(for deletableTasksVMs: [TaskDeletableViewModel]) {
        let alert = deleteAlertFactory.makeAlert(deletableTasksVMs) { [weak self] deletableVM in
            self?.viewModel?.coordinatorResult.accept(
                .onDeleteTasksConfirmed(deletableVM)
            )
        } onCancel: { [weak self] in
            self?.viewModel?.coordinatorResult.accept(.onDeleteTasksCanceled)
        }

        navigation.present(alert, animated: true)
    }

}
