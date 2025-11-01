import RxCocoa

protocol TaskDetailNavigationEmittable {
    var navigationEvent: Signal<TaskDetailNavigationEvent> { get }
}
