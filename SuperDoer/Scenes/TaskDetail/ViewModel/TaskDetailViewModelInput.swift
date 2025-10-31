import RxRelay

protocol TaskDetailViewModelInput {
    var inputEvent: PublishRelay<TaskDetailViewModelInputEvent> { get }
}
