import UIKit
import RxSwift
import RxRelay
import RxCocoa

final class CustomDateSetterCoordinator: BaseCoordinator {
    enum FinishResult {
        case didDeleteValue
        case didSelectValue(Date)
    }

    private var viewModel: CustomDateSetterNavigationEmittable?

    private let viewController: CustomDateSetterViewController
    override var rootViewController: UIViewController { viewController }

    private let finishResultRelay = PublishRelay<FinishResult>()
    var finishResult: Signal<FinishResult> { finishResultRelay.asSignal() }

    init(parent: Coordinator, initialValue: Date?) {
        let vm = CustomDateSetterViewModel(date: initialValue, defaultDate: Date())
        self.viewModel = vm
        self.viewController = CustomDateSetterViewController(viewModel: vm, datePickerMode: .date)
        super.init(parent: parent)
    }

    override func setup() {
        super.setup()

        self.viewModel?.navigationEvent.emit(onNext: { [weak self] event in
            self?.handleNavigationEvent(event)
        })
        .disposed(by: disposeBag)
    }

    // MARK: - Actions handlers

    private func handleNavigationEvent(_ event: CustomDateSetterNavigationEvent) {
        switch event {
        case .didSelectValue(let date):
            finishResultRelay.accept(.didSelectValue(date))

        case .didDeleteValue:
            finishResultRelay.accept(.didDeleteValue)
        }

        rootViewController.dismiss(animated: true)
    }

}
