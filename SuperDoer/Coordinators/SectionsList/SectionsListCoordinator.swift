import UIKit
import Foundation
import RxRelay
import RxCocoa

final class SectionsListCoordinator: BaseCoordinator {

    private let navigation: UINavigationController
    private weak var viewController: SectionsListViewController?
    private let deleteAlertFactory: DeleteItemsAlertFactory

    private let viewModelEventRelay = PublishRelay<SectionsListCoordinatorToVmEvent>()

    init(
        parent: Coordinator,
        navigation: UINavigationController,
        deleteAlertFactory: DeleteItemsAlertFactory
    ) {
        self.navigation = navigation
        self.deleteAlertFactory = deleteAlertFactory
        super.init(parent: parent)
        self.navigation.delegate = self
    }

    override func start() {
        let vm = SectionsListViewModel(
            coordinator: self,
            sectionEm: DIContainer.container.resolve(TaskSectionEntityManager.self)!,
            systemSectionsBuilder: DIContainer.container.resolve(SystemSectionsBuilder.self)!
        )
        let vc = SectionsListViewController(viewModel: vm)

        self.viewController = vc
        navigation.pushViewController(vc, animated: false)
    }
}

// MARK: - SectionsListCoordinatorType

extension SectionsListCoordinator: SectionsListCoordinatorType {
    var viewModelEventSignal: Signal<SectionsListCoordinatorToVmEvent> {
        viewModelEventRelay.asSignal()
    }

    func startTasksInSectionFlow(_ section: TaskSectionProtocol) {
        switch section {
        case let customSection as CDTaskCustomSection:
            startTasksInCustomSectionFlow(customSection)

        case _ as TaskSystemSection:
            print("📋 Открыть системный список")
            // TODO: создать тип для системного списка (там будут другие параметры, скорей всего)
            return

        default:
            print("❌ Ошибка - незивестный тип списка")
        }
    }

    private func startTasksInCustomSectionFlow(_ section: CDTaskCustomSection) {
        let coordinator = TasksListCoordinator(
            parent: self,
            navigation: navigation,
            section: section,
            deleteAlertFactory: DIContainer.container.resolve(DeleteItemsAlertFactory.self)!
        )

        addChild(coordinator)
        coordinator.start()
    }

    func startDeleteSectionConfirmation(_ section: CDTaskCustomSection, _ indexPath: IndexPath) {
        let deletableSectionVM = TaskSectionDeletableViewModel(
            title: section.title ?? "",
            indexPath: indexPath
        )

        let alert = deleteAlertFactory.makeAlert([deletableSectionVM]) { [weak self] items in
            guard let items = items as? [TaskSectionDeletableViewModel] else { return }
            self?.viewModelEventRelay.accept(
                .onDeleteSectionConfirmed(items)
            )
        } onCancel: { [weak self] in
            self?.viewModelEventRelay.accept(.onDeleteSectionCanceled)
        }

        navigation.present(alert, animated: true)
    }

}

// MARK: - UINavigationControllerDelegate

extension SectionsListCoordinator: UINavigationControllerDelegate {
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
