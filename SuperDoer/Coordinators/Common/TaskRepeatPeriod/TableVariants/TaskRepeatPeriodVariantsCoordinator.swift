import RxCocoa
import UIKit

final class TaskRepeatPeriodVariantsCoordinator: BaseCoordinator {
    typealias Value = TaskRepeatPeriod

    private let dependency: TaskRepeatPeriodVariantsDependency<Value>

    override var rootViewController: UIViewController { dependency.viewController }

    private let finishResultRelay = PublishRelay<Value?>()
    var finishResult: Signal<Value?> { finishResultRelay.asSignal() }

    init(parent: Coordinator, initialValue: Value?, factory: TaskRepeatPeriodVariantsFactory) {
        self.dependency = factory.makeDependency(value: initialValue)
        super.init(parent: parent)
    }

    override func setup() {
        super.setup()

        dependency.viewModel.navigationEvent.emit(onNext: { [weak self] event in
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
