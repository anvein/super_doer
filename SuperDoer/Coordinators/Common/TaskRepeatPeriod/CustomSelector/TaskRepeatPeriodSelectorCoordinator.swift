import UIKit
import RxCocoa

final class TaskRepeatPeriodSelectorCoordinator: BaseCoordinator {

    private var viewModel: RepeatPeriodSelectorNavigationEmittable
    private let viewController: RepeatPeriodSelectorViewController

    override var rootViewController: UIViewController { viewController }

    private let finishResultRelay = PublishRelay<TaskRepeatPeriod?>()
    var finishResult: Signal<TaskRepeatPeriod?> { finishResultRelay.asSignal() }

    init(parent: Coordinator, initialValue: TaskRepeatPeriod?) {
        let vm = RepeatPeriodSelectorViewModel(repeatPeriod: initialValue)
        self.viewModel = vm

        self.viewController = RepeatPeriodSelectorViewController(viewModel: vm)
        super.init(parent: parent)
    }

    override func setup() {
        super.setup()

        viewController.title = "Повторять каждые"

        viewModel.navigationEvent.subscribe(onNext: { [weak self] event in
            switch event {
            case .didSelectValue(let repeatPeriod):
                self?.finishResultRelay.accept(repeatPeriod)
                self?.rootViewController.dismissNav()
            }
        })
        .disposed(by: disposeBag)
    }
}
