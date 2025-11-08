import UIKit
import Foundation
import RxRelay
import RxCocoa
import RxSwift

final class SectionsListCoordinator: BaseCoordinator {

    private let navigation: UINavigationController
    private var viewController: SectionsListViewController?
    private var viewModel: (SectionsListCoordinatorResultHandler & SectionsListNavigationEmittable)?
    private let deleteAlertFactory: DeleteItemsAlertFactory

    override var rootViewController: UIViewController? { viewController }

    init(
        parent: Coordinator,
        navigation: UINavigationController,
        deleteAlertFactory: DeleteItemsAlertFactory
    ) {
        self.navigation = navigation
        self.deleteAlertFactory = deleteAlertFactory
        super.init(parent: parent)
    }

    override func startCoordinator() {
        let vm = SectionsListViewModel(
            sectionEm: DIContainer.container.resolve(TaskSectionCoreDataManager.self)!,
            systemSectionsBuilder: DIContainer.container.resolve(SystemSectionsBuilder.self)!
        )
        let vc = SectionsListViewController(viewModel: vm)

        vm.navigationEvent.emit(onNext: { [weak self] event in
            self?.handleNavigationEvent(event)
        })
        .disposed(by: disposeBag)

        self.viewController = vc
        self.viewModel = vm

        navigation.pushViewController(vc, animated: false)
    }

    // MARK: - Start chlids

    private func startTasksListInSystemSectionFlow() {
        print("📋 Открыть системный список")
    }

    private func startTasksListInCustomSectionFlow(with sectionId: UUID) {
        let coordinator = TasksListCoordinator(
            parent: self,
            navigation: navigation,
            sectionId: sectionId,
            deleteAlertFactory: DIContainer.container.resolve(DeleteItemsAlertFactory.self)!
        )

        startChild(coordinator)
    }

    private func startDeleteSectionConfirmation(_ sectionVM: TaskSectionDeletableViewModel) {
        let alert = deleteAlertFactory.makeAlert([sectionVM]) { [weak self] items in
            self?.viewModel?.coordinatorResult.accept(
                .onDeleteSectionConfirmed(items)
            )
        } onCancel: { [weak self] in
            self?.viewModel?.coordinatorResult.accept(.onDeleteSectionCanceled)
        }

        navigation.present(alert, animated: true)
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
