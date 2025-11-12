import UIKit
import RxRelay
import RxCocoa
import RxSwift

final class TasksListCoordinator: BaseCoordinator {

    private let sectionId: UUID?
    private let deleteAlertFactory: DeleteItemsAlertFactory

    private var viewModel: (TasksListNavigationEmittable & TasksListCoordinatorResultHandler)?
    private let viewController: TasksListViewController

    override var rootViewController: UIViewController { viewController }

    init(
        parent: Coordinator,
        sectionId: UUID?,
        deleteAlertFactory: DeleteItemsAlertFactory
    ) {
        self.sectionId = sectionId
        self.deleteAlertFactory = deleteAlertFactory

        let vm = TasksListViewModel(
            repository: DIContainer.container.resolve(TasksListRepository.self, argument: sectionId)!,
            sectionCDManager: DIContainer.container.resolve(TaskSectionCoreDataManager.self)!
        )
        self.viewModel = vm
        self.viewController = TasksListViewController(viewModel: vm)

        super.init(parent: parent)
    }

    override func setup() {
        super.setup()

        viewModel?.navigationEvent.emit(onNext: { [weak self] event in
            self?.handleNavigationEvent(event)
        })
        .disposed(by: disposeBag)
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
            taskId: taskId,
            deleteAlertFactory: DIContainer.container.resolve(DeleteItemsAlertFactory.self)!
        )
        startChild(coordinator) { [weak self] (controller: UIViewController) in
            self?.rootViewController.show(controller, sender: self)
        }
    }

    private func startDeleteTasksConfirmation(for deletableTasksVMs: [TaskDeletableViewModel]) {
        let alert = deleteAlertFactory.makeAlert(deletableTasksVMs) { [weak self] deletableVM in
            self?.viewModel?.coordinatorResult.accept(
                .onDeleteTasksConfirmed(deletableVM)
            )
        } onCancel: { [weak self] in
            self?.viewModel?.coordinatorResult.accept(.onDeleteTasksCanceled)
        }

        rootViewController.present(alert, animated: true)
    }

}
