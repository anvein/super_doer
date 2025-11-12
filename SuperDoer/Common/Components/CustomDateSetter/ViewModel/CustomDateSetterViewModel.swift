import Foundation
import RxCocoa
import RxSwift

class CustomDateSetterViewModel: CustomDateSetterViewModelType, CustomDateSetterNavigationEmittable {
    typealias Value = Date

    private let disposeBag = DisposeBag()

    // MARK: - State

    private var dateRelay: BehaviorRelay<Date>
    private let defaultDate: Value

    private let isShowReadyButtonRelay = BehaviorRelay<Bool>(value: true)
    private let isShowDeleteButtonRelay = BehaviorRelay<Bool>(value: false)

    // MARK: - Output

    var date: Driver<Value> { dateRelay.asDriver() }
    var isShowReadyButton: Driver<Bool> { isShowReadyButtonRelay.asDriver() }
    var isShowDeleteButton: Driver<Bool> { isShowDeleteButtonRelay.asDriver() }

    // MARK: - Input

    var inputEvents = PublishRelay<CustomDateSetterInputEvent>()

    // MARK: - Navigation

    var navigationEvent: Signal<CustomDateSetterNavigationEvent> { navigationEventRelay.asSignal() }
    let navigationEventRelay = PublishRelay<CustomDateSetterNavigationEvent>()

    // MARK: - Init

    init(date: Value?, defaultDate: Value) {
        self.defaultDate = defaultDate
        self.dateRelay = .init(value: date ?? defaultDate)

        setupBindings()
    }

    // MARK: - Setup

    private func setupBindings() {
        inputEvents.subscribe(onNext: { [weak self] event in
            self?.handleInputEvent(event)
        })
        .disposed(by: disposeBag)

    }

    // MARK: - Actions handlers

    private func handleInputEvent(_ event: CustomDateSetterInputEvent) {
        switch event {
        case .didTapReady:
            navigationEventRelay.accept(.didSelectValue(dateRelay.value))

        case .didSelectDate(let date):
            dateRelay.accept(date)

        case .didTapDelete:
            navigationEventRelay.accept(.didDeleteValue)
        }
    }

}
