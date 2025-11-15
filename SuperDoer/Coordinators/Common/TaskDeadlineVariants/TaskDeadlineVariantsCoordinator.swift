import UIKit
import RxCocoa
import RxSwift

final class TaskDeadlineVariantsCoordinator: BaseCoordinator {

    private var viewModel: AnyTableVariantsNavigationEmittable<Date>
    private let viewController: TableVariantsViewController

    override var rootViewController: UIViewController { viewController }

    private let finishResultRelay = PublishRelay<Date?>()
    var finishResult: Signal<Date?> { finishResultRelay.asSignal() }

    init(parent: Coordinator, value: Date?) {
        let vm = TableVariantsViewModel(
            value: value,
            variantsFactory: DIContainer.container.resolve(TaskDeadlineVariantsFactory.self)!,
            selectedVariantFinder: DIContainer.container.resolve(TaskDeadlineTableVariantFinder.self)!
        )
        self.viewModel = AnyTableVariantsNavigationEmittable(vm)
        self.viewController = TableVariantsViewController(
            viewModel: vm,
            detent: .taskDeadlineVariants,
            title: "Срок"
        )

        super.init(parent: parent)
    }

    override func setup() {
        super.setup()

        viewModel.navigationEvent.emit(onNext: { [weak self] event in
            self?.handleNavigationEvent(event)
        })
        .disposed(by: disposeBag)
    }

    // MARK: - Start childs

    private func startCustomDateSetterCoordinator(with date: Date?) {
        let coordinator = CustomDateSetterCoordinator(
            parent: self,
            mode: .date,
            initialValue: date
        )

        coordinator.finishResult.emit(onNext: { [weak self] result in
            self?.handleCustomDateSetterResult(result)
        })
        .disposed(by: disposeBag)

        startChild(coordinator) { [weak self] (controller: UIViewController) in
            self?.rootViewController.show(controller, sender: self)
        }
    }

    // MARK: - Actions handlers

    private func handleNavigationEvent(_ event: TableVariantsNavigationEvent<Date>) {
        switch event {
        case .didSelectValue(let date):
            finishResultRelay.accept(date)
            rootViewController.dismiss(animated: true)

        case .didSelectCustomVariant(let date):
            startCustomDateSetterCoordinator(with: date)
        }
    }

    private func handleCustomDateSetterResult(
        _ resultEvent: CustomDateSetterCoordinator.FinishResult
    ) {
        switch resultEvent {
        case .didDeleteValue:
            finishResultRelay.accept(nil)

        case .didSelectValue(let date):
            finishResultRelay.accept(date)
        }
    }

}
