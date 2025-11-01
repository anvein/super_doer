import RxRelay

protocol TasksListCoordinatorResultHandler: AnyObject {
    var coordinatorResult: PublishRelay<TasksListCoordinatorResult> { get }
}
