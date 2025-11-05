import UIKit
import RxCocoa
import RxSwift

class TaskDeadlineVariantsCoordinator: BaseCoordinator {
    typealias Value = TaskDeadlineVariantsViewModel.Value

    private weak var viewModel: TaskDeadlineVariantsNavigationEmittable?
    private var navigation: UINavigationController?

    private let navigationMethod: CoordinatorNavigationMethod
    private let value: Value?

    private let finishResultRelay = PublishRelay<Value?>()
    var finishResult: Signal<Value?> { finishResultRelay.asSignal() }

    let disposeBag = DisposeBag()

    init(parent: Coordinator, navigationMethod: CoordinatorNavigationMethod, value: Value?) {
        self.navigationMethod = navigationMethod
        self.value = value
        super.init(parent: parent)
    }

    override func start() {
        super.start()

        let vm = TaskDeadlineVariantsViewModel(
            deadlineDate: value,
            variantsFactory: DIContainer.container.resolve(TaskDeadlineVariantsFactory.self)!
        )
        let vc = TableVariantsViewController(
            viewModel: vm,
            detent: .taskDeadlineVariants,
            title: "Срок"
        )
        self.viewModel = vm

        self.viewModel?.navigationEvent.emit(onNext: { [weak self] event in
            self?.handleNavigationEvent(event)
        })
        .disposed(by: disposeBag)

        // TODO: переделать на Router
        switch navigationMethod {
        case .push(let toNavigation, let withAnimation):
            navigation = toNavigation
            toNavigation.pushViewController(vc, animated: withAnimation)

        case .presentWithNavigation(let parentController):
            let navigation = UINavigationController(rootViewController: vc)

            navigation.view.backgroundColor = .white
            parentController.present(navigation, animated: true)
            self.navigation = navigation

        case .presentWithoutNavigation(let parentController):
            parentController.present(vc, animated: true)
        }
    }

    // MARK: - Actions handlers

    private func handleNavigationEvent(_ event: TaskDeadlineVariantsNavigationEvent) {
        switch event {
        case .didSelectValue(let date), .didSelectReady(let date):
            // TODO: переделать на Router, который будет всем рулить
            guard case .presentWithNavigation(_) = navigationMethod,
                  let navigation else { return }

            navigation.dismiss(animated: true)
            finishResultRelay.accept(date)
            finish()

        case .openCustomDateSetter(let date):
            startCustomDateSetterCoordinator(with: date)
        }

    }

    // MARK: - Start childs

    private func startCustomDateSetterCoordinator(with date: Date?) {
        guard case .presentWithNavigation(_) = navigationMethod,
              let navigation else { return }

        let coordinator = CustomDateSetterCoordinator(
            parent: self,
            navigation: navigation,
            delegate: self,
            value: date
        )
        addChild(coordinator)
        coordinator.start()
    }
}

//// MARK: - coordinator methods for ContainerNavigationController
//extension TaskDeadlineDateVariantsCoordinator: ContainerNavigationControllerCoordinator {
//    func didCloseContainerNavigation() {
//        parent?.removeChild(self)
//    }
//}
//
//
// MARK: - delegates of child coordinators
extension TaskDeadlineVariantsCoordinator: TaskDeadlineDateCustomCoordinatorDelegate {
    func didChooseTaskDeadlineDate(newDate: Date?) {
//        self.delegate?.didChooseTaskDeadlineDate(newDate: newDate)
    }
}
