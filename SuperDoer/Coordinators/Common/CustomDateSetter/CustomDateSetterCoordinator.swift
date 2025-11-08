import UIKit
import RxSwift
import RxRelay
import RxCocoa

final class CustomDateSetterCoordinator: BaseCoordinator {
    enum FinishResult {
        case didDeleteValue
        case didSelectValue(Date)
    }

    private var navigation: UINavigationController
    private var viewModel: CustomDateSetterNavigationEmittable?

    private var viewController: CustomDateSetterViewController?
    override var rootViewController: UIViewController? { viewController }

    private let initialValue: Date?

    private let finishResultRelay = PublishRelay<FinishResult>()
    var finishResult: Signal<FinishResult> { finishResultRelay.asSignal() }

    init(
        parent: Coordinator,
        navigation: UINavigationController,
        initialValue: Date?
    ) {
        self.navigation = navigation
        self.initialValue = initialValue
        super.init(parent: parent)
    }
    
    override func startCoordinator() {
        let viewModel = CustomDateSetterViewModel(date: initialValue, defaultDate: Date())
        let controller = CustomDateSetterViewController(
            viewModel: viewModel,
            datePickerMode: .date
        )

        self.viewController = controller
        self.viewModel = viewModel
        self.viewModel?.navigationEvent.emit(onNext: { [weak self] event in
            self?.handleNavigationEvent(event)
        })
        .disposed(by: disposeBag)

        navigation.pushViewController(controller, animated: true)
    }

    // MARK: - Actions handlers

    private func handleNavigationEvent(_ event: CustomDateSetterNavigationEvent) {
        switch event {
        case .didSelectValue(let date):
            finishResultRelay.accept(.didSelectValue(date))

        case .didDeleteValue:
            finishResultRelay.accept(.didDeleteValue)
        }

        navigation.dismiss(animated: true)
    }

}
