protocol TaskSectionsListViewControllerCoordinator: AnyObject {
    func startTasksInSectionFlow(_ section: TaskSectionProtocol)

    func startDeleteProcessSection(_ section: TaskSectionDeletableViewModel)

    func finish()
}
