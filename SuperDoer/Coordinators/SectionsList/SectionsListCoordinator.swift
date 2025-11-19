import Foundation
import RxCocoa
import RxRelay
import RxSwift
import UIKit

final class SectionsListCoordinator: BaseCoordinator {

    private let dependency: SectionsListDependency
    private let factory: SectionsListDependencyFactoryType

    override var rootViewController: UIViewController { dependency.viewController }

    init(parent: Coordinator, factory: SectionsListDependencyFactoryType) {
        self.factory = factory
        self.dependency = factory.makeDependency()
        super.init(parent: parent)
    }

    override func setup() {
        super.setup()

        dependency.viewModel.navigationEvent.emit(onNext: { [weak self] event in
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
            factory: factory.tasksListFactory
        )

        startChild(coordinator) { [weak self] controller in
            self?.rootViewController.show(controller, sender: self)
        }
    }

    private func startDeleteSectionConfirmation(_ sectionVM: TaskSectionDeletableViewModel) {
        let alert = dependency.deleteAlertFactory.makeAlert([sectionVM]) { [weak self] items in
            self?.dependency.viewModel.coordinatorResult.accept(
                .onDeleteSectionConfirmed(items)
            )
        } onCancel: { [weak self] in
            self?.dependency.viewModel.coordinatorResult.accept(.onDeleteSectionCanceled)
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
