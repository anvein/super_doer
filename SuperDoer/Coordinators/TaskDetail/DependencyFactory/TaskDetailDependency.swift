struct TaskDetailDependency {
    let viewModel: TaskDetailNavigationEmittable & TaskDetailCoordinatorResultHandler
    let viewController: TaskDetailViewController

    let deleteAlertFactory: DeleteItemsAlertFactory
}
