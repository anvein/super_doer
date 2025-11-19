import Foundation

protocol TasksListDependencyFactoryType {
    var taskDetailFactory: TaskDetailDependencyFactoryType { get }

    func makeDependency(sectionId: UUID?) -> TasksListDependency
}
