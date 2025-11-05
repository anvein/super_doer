import Foundation

enum TaskDeadlineVariantsNavigationEvent {
    case didSelectValue(TaskDeadlineVariantsCoordinator.Value?)
    case openCustomDateSetter(TaskDeadlineVariantsCoordinator.Value?)
    case didSelectReady(TaskDeadlineVariantsCoordinator.Value?)
}
