import RxCocoa

protocol TaskDetailNavigationEmittable: AnyObject {
    var navigationEvent: Signal<TaskDetailNavigationEvent> { get }
}
