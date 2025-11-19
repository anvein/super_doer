import Foundation

protocol TaskDetailDependencyFactoryType {
    var importFileSourceAlertFactory: ImportFileSourceAlertFactory { get }
    var notificationsDisabledAlertFactory: NotificationsDisabledAlertFactory { get }
    var taskDeadlineVariantsFactory: TaskDeadlineVariantsFactoryType { get }
    var taskRepeatPeriodVariantsFactory: TaskRepeatPeriodVariantsFactory { get }

    func makeDependency(taskId: UUID) -> TaskDetailDependency
}
