import RxCocoa

protocol TasksListNavigationEmittable: AnyObject {
    var navigationEvent: Signal<TasksListNavigationEvent> { get }
}
