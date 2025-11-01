import RxCocoa

protocol SectionsListNavigationEmittable {
    var navigationEvent: Signal<SectionsListNavigationEvent> { get }
}
