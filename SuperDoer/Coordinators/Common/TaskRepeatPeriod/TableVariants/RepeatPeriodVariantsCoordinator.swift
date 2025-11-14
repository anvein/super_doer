import UIKit
import RxCocoa

final class TaskRepeatPeriodVariantsCoordinator: BaseCoordinator {
    typealias Value = TaskRepeatPeriod

    private var viewModel: AnyTableVariantsNavigationEmittable<Value>
    private var viewController: TableVariantsViewController

    override var rootViewController: UIViewController { viewController }

    private let finishResultRelay = PublishRelay<Value?>()
    var finishResult: Signal<Value?> { finishResultRelay.asSignal() }

    init(parent: Coordinator, initialValue: Value?) {
        let vm = TableVariantsViewModel(
            value: initialValue,
            variantsFactory: DIContainer.container.resolve(TaskRepeatPeriodVariantsFactory.self)!,
            selectedVariantFinder: DIContainer.container.resolve(TaskRepeatPeriodTableVariantFinder.self)!
        )
        self.viewModel = AnyTableVariantsNavigationEmittable(vm)

        self.viewController = TableVariantsViewController(
            viewModel: vm,
            detent: .taskRepeatPeriodVariants,
            title: "Повтор"
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

    private func startCustomTaskRepeatPeriodCoordinator(with value: Value?) {
        let coordinator = TaskRepeatPeriodSelectorCoordinator(
            parent: self,
            initialValue: value
        )

        coordinator.finishResult.emit(onNext: { [weak self] result in
            self?.finishResultRelay.accept(result)
        })
        .disposed(by: coordinator.disposeBag)

        startChild(coordinator) { [weak self] controller in
            self?.rootViewController.show(controller, sender: self)
        }
    }

    // MARK: - Actions handlers

    private func handleNavigationEvent(_ event: TableVariantsNavigationEvent<Value>) {
        switch event {
        case .didSelectValue(let value):
            finishResultRelay.accept(value)
            rootViewController.dismissNav()

        case .didSelectCustomVariant(let value):
            startCustomTaskRepeatPeriodCoordinator(with: value)
        }
    }
}

