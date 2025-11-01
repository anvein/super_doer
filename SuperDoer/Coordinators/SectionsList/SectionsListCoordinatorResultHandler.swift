import RxRelay

protocol SectionsListCoordinatorResultHandler {
    var coordinatorResult: PublishRelay<SectionsListCoordinatorResult> { get }
}
