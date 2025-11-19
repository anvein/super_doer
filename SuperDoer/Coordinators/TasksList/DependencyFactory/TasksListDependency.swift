struct TasksListDependency {
    let viewModel: TasksListNavigationEmittable & TasksListCoordinatorResultHandler
    let viewController: TasksListViewController

    let deleteAlertFactory: DeleteItemsAlertFactory
}
