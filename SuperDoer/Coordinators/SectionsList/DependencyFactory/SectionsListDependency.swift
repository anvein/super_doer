struct SectionsListDependency {
    let viewController: SectionsListViewController
    let viewModel: SectionsListCoordinatorResultHandler & SectionsListNavigationEmittable
    let deleteAlertFactory: DeleteItemsAlertFactory
}
