import RxCocoa

protocol TaskDeadlineVariantsNavigationEmittable: AnyObject {
    var navigationEvent: Signal<TaskDeadlineVariantsNavigationEvent> { get }
}
