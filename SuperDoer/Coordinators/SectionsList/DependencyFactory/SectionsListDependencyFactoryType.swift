protocol SectionsListDependencyFactoryType {

    var tasksListFactory: TasksListDependencyFactoryType { get }

    func makeDependency() -> SectionsListDependency
}
