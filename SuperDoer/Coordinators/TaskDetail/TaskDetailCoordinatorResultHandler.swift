import RxRelay

protocol TaskDetailCoordinatorResultHandler {
    var coordinatorResult: PublishRelay<TaskDetailCoordinatorResult> { get }
}
