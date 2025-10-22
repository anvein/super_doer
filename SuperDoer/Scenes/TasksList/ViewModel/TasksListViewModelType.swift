import Foundation
import RxCocoa

protocol TasksListViewModelType {
    
    var sectionTitleDriver: Driver<String> { get }
    var tableUpdateEventsSignal: Signal<TaskListTableUpdateEvent> { get }

    func loadInitialData()

    func getSectionsCount() -> Int
    func getTasksCountInSection(with index: Int) -> Int

    func getTasksTableViewCellVM(forIndexPath indexPath: IndexPath) -> TaskTableViewCellViewModelType
    
    func getTaskDetailViewModel(for indexPath: IndexPath) -> TaskDetailViewModel?
    
    func getTasksDeletableViewModels(for indexPaths: [IndexPath]) -> [TaskDeletableViewModel]

    func createNewTaskInCurrentSection(with data: TaskCreateData)

    func switchTaskFieldIsCompletedWith(indexPath: IndexPath)
    func switchTaskFieldIsPriorityWith(indexPath: IndexPath)
    func switchTaskFieldInMyDayWith(indexPath: IndexPath)

    func deleteTasks(taskViewModels: [DeletableItemViewModelType])
    
    func moveTasksInCurrentList(fromPath: IndexPath, to toPath: IndexPath)
    
}
