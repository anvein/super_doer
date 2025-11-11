import UIKit
import Foundation
import RxRelay
import RxCocoa
import RxSwift

final class SectionsListCoordinator: BaseCoordinator {

    private weak var viewModel: (SectionsListCoordinatorResultHandler & SectionsListNavigationEmittable)?
    private let deleteAlertFactory: DeleteItemsAlertFactory

    private let viewController: SectionsListViewController
    override var rootViewController: UIViewController { viewController }

    init(
        parent: Coordinator,
        deleteAlertFactory: DeleteItemsAlertFactory
    ) {
        let vm = SectionsListViewModel(
            sectionEm: DIContainer.container.resolve(TaskSectionCoreDataManager.self)!,
            systemSectionsBuilder: DIContainer.container.resolve(SystemSectionsBuilder.self)!
        )
        self.viewModel = vm
        self.viewController = SectionsListViewController(viewModel: vm)

        self.deleteAlertFactory = deleteAlertFactory
        super.init(parent: parent)
    }

    override func setup() {
        super.setup()

        viewModel?.navigationEvent.emit(onNext: { [weak self] event in
            self?.handleNavigationEvent(event)
        })
        .disposed(by: disposeBag)
    }

    // MARK: - Start chlids

    private func startTasksListInSystemSectionFlow() {
        print("📋 Открыть системный список")
    }

    private func startTasksListInCustomSectionFlow(with sectionId: UUID) {
        let coordinator = TasksListCoordinator(
            parent: self,
            sectionId: sectionId,
            deleteAlertFactory: DIContainer.container.resolve(DeleteItemsAlertFactory.self)!
        )

        startChild(coordinator) { [weak self] controller in
            self?.rootViewController.show(controller, sender: self)
        }
    }

    private func startDeleteSectionConfirmation(_ sectionVM: TaskSectionDeletableViewModel) {
        let alert = deleteAlertFactory.makeAlert([sectionVM]) { [weak self] items in
            self?.viewModel?.coordinatorResult.accept(
                .onDeleteSectionConfirmed(items)
            )
        } onCancel: { [weak self] in
            self?.viewModel?.coordinatorResult.accept(.onDeleteSectionCanceled)
        }

        rootViewController.present(alert, animated: true)
    }

    // MARK: - Actions handlers

    private func handleNavigationEvent(_ event: SectionsListNavigationEvent) {
        switch event {
        case .openDeleteSectionConfirmation(let sectionVM):
            startDeleteSectionConfirmation(sectionVM)

        case .openTasksListInCustomSection(let sectionId):
            startTasksListInCustomSectionFlow(with: sectionId)

        case .openTasksListInSystemSection:
            startTasksListInSystemSectionFlow()
        }
    }
}
