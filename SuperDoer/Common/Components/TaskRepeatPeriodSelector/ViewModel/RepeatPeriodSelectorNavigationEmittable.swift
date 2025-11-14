import RxRelay

protocol RepeatPeriodSelectorNavigationEmittable {
    var navigationEvent: PublishRelay<RepeatPeriodSelectorNavigationEvent> { get }
}
