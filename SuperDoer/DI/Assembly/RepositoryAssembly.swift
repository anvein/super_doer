import Swinject

// swiftlint:disable force_unwrapping
final class RepositoryAssembly: Assembly {
    func assemble(container: Container) {
        container.register(TasksListRepository.self) { r, arg1 in
            return TasksListRepository(
                sectionId: arg1,
                sectionCDManager: r.resolve(TaskSectionCoreDataManager.self)!,
                taskCDManager: r.resolve(TaskCoreDataManager.self)!
            )
        }.inObjectScope(.graph)
    }

}
// swiftlint:enable force_unwrapping
