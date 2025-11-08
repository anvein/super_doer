import UIKit
import RxCocoa
import RxSwift

class TaskDeadlineVariantsCoordinator: BaseCoordinator {
    typealias Value = TaskDeadlineVariantsViewModel.Value

    override var rootViewController: UIViewController? { viewController }
    private var viewController: TableVariantsViewController?

    private var viewModel: TaskDeadlineVariantsNavigationEmittable?

    private let navigationMethod: CoordinatorNavigationMethod
    private let value: Value?

    private let finishResultRelay = PublishRelay<Value?>()
    var finishResult: Signal<Value?> { finishResultRelay.asSignal() }

    init(parent: Coordinator, navigationMethod: CoordinatorNavigationMethod, value: Value?) {
        self.navigationMethod = navigationMethod
        self.value = value
        super.init(parent: parent)
    }

    override func startCoordinator() {
        let vm = TaskDeadlineVariantsViewModel(
            deadlineDate: value,
            variantsFactory: DIContainer.container.resolve(TaskDeadlineVariantsFactory.self)!
        )
        let vc = TableVariantsViewController(
            viewModel: vm,
            detent: .taskDeadlineVariants,
            title: "Срок"
        )

        self.viewController = vc
        self.viewModel = vm

        self.viewModel?.navigationEvent.emit(onNext: { [weak self] event in
            self?.handleNavigationEvent(event)
        })
        .disposed(by: disposeBag)

        // TODO: переделать на Router
        switch navigationMethod {
        case .push(let toNavigation, let withAnimation):
            toNavigation.pushViewController(vc, animated: withAnimation)

        case .presentModallyWithNav(let navigation, let parentController):
            navigation.view.backgroundColor = .white
            navigation.setViewControllers([vc], animated: true)
            parentController.present(navigation, animated: true)

        case .presentModally(let parentController):
            parentController.present(vc, animated: true)
        }
    }

    // MARK: - Start childs

    private func startCustomDateSetterCoordinator(with date: Date?) {
        guard case .presentModallyWithNav(let navigation, _) = navigationMethod else { return }

        let coordinator = CustomDateSetterCoordinator(
            parent: self,
            navigation: navigation,
            initialValue: date
        )

        coordinator.finishResult.emit(onNext: { [weak self] result in
            self?.handleCustomDateSetterResult(result)
        })
        .disposed(by: disposeBag)

        startChild(coordinator)
    }

    // MARK: - Actions handlers

    private func handleNavigationEvent(_ event: TaskDeadlineVariantsNavigationEvent) {
        switch event {
        case .didSelectValue(let date), .didSelectReady(let date):
            // TODO: переделать на Router, который будет всем рулить
            guard case .presentModallyWithNav(let navigation, _) = navigationMethod else { return }

            finishResultRelay.accept(date)
            navigation.dismiss(animated: true)

        case .openCustomDateSetter(let date):
            startCustomDateSetterCoordinator(with: date)
        }
    }

    private func handleCustomDateSetterResult(
        _ resultEvent: CustomDateSetterCoordinator.FinishResult
    ) {
        // TODO: переделать на Router, который будет всем рулить
        guard case .presentModallyWithNav(let navigation, _) = navigationMethod else { return }

        switch resultEvent {
        case .didDeleteValue:
            finishResultRelay.accept(nil)

        case .didSelectValue(let date):
            finishResultRelay.accept(date)
        }
    }

}
