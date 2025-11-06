import RxCocoa

protocol CustomDateSetterNavigationEmittable {
    var navigationEvent: Signal<CustomDateSetterNavigationEvent> { get }
}
