import RxCocoa
import RxRelay
import RxSwift
import UIKit

final class TasksListCoordinator: BaseCoordinator {

    private let factory: TasksListDependencyFactoryType
    private let dependency: TasksListDependency

    override var rootViewController: UIViewController { dependency.viewController }

    init(parent: Coordinator, section: TasksListSection, factory: TasksListDependencyFactoryType) {
        self.factory = factory
        self.dependency = factory.makeDependency(section: section)
        super.init(parent: parent)
    }

    override func setup() {
        super.setup()

        dependency.viewModel.navigationEvent.emit(onNext: { [weak self] event in
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
            factory: factory.taskDetailFactory
        )
        startChild(coordinator) { [weak self] (controller: UIViewController) in
            self?.rootViewController.show(controller, sender: self)
        }
    }

    private func startDeleteTasksConfirmation(for deletableTasksVMs: [TaskDeletableViewModel]) {
        let alert = dependency.deleteAlertFactory.makeAlert(deletableTasksVMs) { [weak self] deletableVM in
            self?.dependency.viewModel.coordinatorResult.accept(
                .onDeleteTasksConfirmed(deletableVM)
            )
        } onCancel: { [weak self] in
            self?.dependency.viewModel.coordinatorResult.accept(.onDeleteTasksCanceled)
        }

        rootViewController.present(alert, animated: true)
    }

}
