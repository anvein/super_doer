import UIKit
import RxCocoa
import RxSwift

class TaskDeadlineVariantsCoordinator: BaseCoordinator {
    typealias Value = TaskDeadlineVariantsViewModel.Value

    private var viewModel: TaskDeadlineVariantsNavigationEmittable?
    private let viewController: TableVariantsViewController

    override var rootViewController: UIViewController { viewController }

    private let finishResultRelay = PublishRelay<Value?>()
    var finishResult: Signal<Value?> { finishResultRelay.asSignal() }

    init(parent: Coordinator, value: Value?) {
        let vm = TaskDeadlineVariantsViewModel(
            deadlineDate: value,
            variantsFactory: DIContainer.container.resolve(TaskDeadlineVariantsFactory.self)!
        )
        self.viewModel = vm
        self.viewController =  TableVariantsViewController(
            viewModel: vm,
            detent: .taskDeadlineVariants,
            title: "Срок"
        )

        super.init(parent: parent)
    }

    override func setup() {
        super.setup()
        
        self.viewModel?.navigationEvent.emit(onNext: { [weak self] event in
            self?.handleNavigationEvent(event)
        })
        .disposed(by: disposeBag)
    }

    // MARK: - Start childs

    private func startCustomDateSetterCoordinator(with date: Date?) {
        let coordinator = CustomDateSetterCoordinator(parent: self, initialValue: date)

        coordinator.finishResult.emit(onNext: { [weak self] result in
            self?.handleCustomDateSetterResult(result)
        })
        .disposed(by: disposeBag)

        startChild(coordinator) { [weak self] (controller: UIViewController) in
            self?.rootViewController.show(controller, sender: self)
        }
    }

    // MARK: - Actions handlers

    private func handleNavigationEvent(_ event: TaskDeadlineVariantsNavigationEvent) {
        switch event {
        case .didSelectValue(let date), .didSelectReady(let date):
            finishResultRelay.accept(date)
            rootViewController.dismiss(animated: true)

        case .openCustomDateSetter(let date):
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
