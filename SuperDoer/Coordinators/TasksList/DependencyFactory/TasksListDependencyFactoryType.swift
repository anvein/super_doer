import Foundation

protocol TasksListDependencyFactoryType {
    var taskDetailFactory: TaskDetailDependencyFactoryType { get }

    func makeDependency(section: TasksListSection) -> TasksListDependency
}
