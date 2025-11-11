import RxRelay

protocol TaskDetailCoordinatorResultHandler: AnyObject {
    var coordinatorResult: PublishRelay<TaskDetailCoordinatorResult> { get }
}
