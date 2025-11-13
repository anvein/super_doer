import RxCocoa

protocol TableVariantsNavigationEmittable: AnyObject {
    associatedtype NavigationValue
    var navigationEvent: Signal<TableVariantsNavigationEvent<NavigationValue>> { get }
}
