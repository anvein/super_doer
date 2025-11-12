import RxCocoa

protocol SectionsListNavigationEmittable: AnyObject {
    var navigationEvent: Signal<SectionsListNavigationEvent> { get }
}
