import Foundation
import RxCocoa

protocol TasksListViewModelType {

    var sectionTitleDriver: Driver<String> { get }
    var tableUpdateEventsSignal: Signal<TaskListTableUpdateEvent> { get }
    var errorMessageSignal: Signal<String> { get }

    func getSectionsCount() -> Int
    func getTasksCountInSection(with index: Int) -> Int
    func getTableCellVM(for indexPath: IndexPath) -> TaskTableCellViewModelType

    func needLoadInitialData()

    func didTapOpenTask(with indexPath: IndexPath)
    func didTapDeleteTask(with indexPath: IndexPath)
    func didTapDeleteTasks(with indexPaths: [IndexPath])

    func didToggleTaskInMyDay(with indexPath: IndexPath)
    func didTapTaskIsCompleted(_ newValue: Bool, with indexPath: IndexPath)
    func didTapTaskIsPriority(_ newValue: Bool, with indexPath: IndexPath)

    func didTapCreateTaskInCurrentSection(with data: TaskCreateData)
    func didMoveEndTasksInCurrentSection(from: IndexPath, to toPath: IndexPath)

    func didConfirmRenameSectionTitle(_ title: String)

}
