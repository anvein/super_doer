import Swinject
import Foundation

// swiftlint:disable force_unwrapping
final class TaskDetailDependencyFactory: TaskDetailDependencyFactoryType {

    private let resolver: Resolver

    var importFileSourceAlertFactory: ImportFileSourceAlertFactory {
        resolver.resolve(ImportFileSourceAlertFactory.self)!
    }

    var notificationsDisabledAlertFactory: NotificationsDisabledAlertFactory {
        resolver.resolve(NotificationsDisabledAlertFactory.self)!
    }

    var taskDeadlineVariantsFactory: any TaskDeadlineVariantsFactoryType {
        resolver.resolve(TaskDeadlineVariantsFactoryType.self)!
    }

    var taskRepeatPeriodVariantsFactory: TaskRepeatPeriodVariantsFactory {
        resolver.resolve(TaskRepeatPeriodVariantsFactory.self)!
    }

    init(resolver: Resolver) {
        self.resolver = resolver
    }

    func makeDependency(taskId: UUID) -> TaskDetailDependency {
        let vm = TaskDetailViewModel(
            taskId: taskId,
            taskRepository: resolver.resolve(TaskRepository.self)!
        )
        let vc = TaskDetailViewController(viewModel: vm)

        return .init(
            viewModel: vm,
            viewController: vc,
            deleteAlertFactory: resolver.resolve(DeleteItemsAlertFactory.self)!
        )
    }

}
// swiftlint:enable force_unwrapping
