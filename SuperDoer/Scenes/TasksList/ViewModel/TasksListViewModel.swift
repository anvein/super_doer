
import Foundation
import RxSwift
import RxCocoa

class TasksListViewModel: TasksListViewModelType {

    private let disposeBag = DisposeBag()

    // MARK: - Model

    private let model: TasksListModel

    // MARK: - State

    private let sectionTitleRelay = BehaviorRelay<String>(value: "")
    private let tableUpdateEventsRelay = PublishRelay<TableUpdateEvent>()

    // MARK: - Observable

    var sectionTitleDriver: Driver<String> { sectionTitleRelay.asDriver() }
    var tableUpdateEventsSignal: Signal<TableUpdateEvent> { tableUpdateEventsRelay.asSignal() }

    // MARK: - Init

    init(model: TasksListModel) {
        self.model = model

        sectionTitleRelay.accept(model.getSectionTitle() ?? "")

        setupBindings()
    }

    // MARK: - Setup

    private func setupBindings() {
        // M -> VM
        model.modelUpdatedObservable
            .subscribe(onNext: { [weak self] event in
                self?.handleModelUpdatedEvent(event)
            })
            .disposed(by: disposeBag)
    }

    // MARK: -

    func viewDidLoad() {
        model.loadTasks()
    }

    // MARK: get data for VC methods

    func getSectionsCount() -> Int {
        return model.getSectionsCount()
    }

    func getTasksCountIn(section: Int) -> Int {
        return model.getTasksCountIn(in: section)
    }

    func getTaskTableViewCellViewModel(forIndexPath indexPath: IndexPath) -> TaskTableViewCellViewModelType  {
        let task = model.getTask(for: indexPath)
        return TaskTableViewCellViewModel(task: task)
    }

    func getTaskDetailViewModel(forIndexPath indexPath: IndexPath) -> TaskDetailViewModel? {
        let selectedTask = model.getTask(for: indexPath)
        guard let taskId = selectedTask.id else { return nil }

        return TaskDetailViewModel(
            taskId,
            taskEm: DIContainer.shared.resolve(TaskCoreDataManager.self)!,
            taskFileEm: DIContainer.shared.resolve(TaskFileEntityManager.self)!
        )
    }

    func getTaskDeletableViewModels(forIndexPaths indexPaths: [IndexPath]) -> [TaskDeletableViewModel] {
        var viewModels: [TaskDeletableViewModel] = []
        for indexPath in indexPaths {
            let viewModel = TaskDeletableViewModel(
                task: model.getTask(for: indexPath),
                indexPath: indexPath
            )
            viewModels.append(viewModel)
        }

        return viewModels
    }

    // MARK: model manipulation methods
    func createNewTaskInCurrentSectionWith(
        title: String,
        inMyDay: Bool,
        reminderDateTime: Date?,
        deadlineAt: Date?,
        description: String?
    ) {
        model.createTaskInCurrentSectionWith(title: title)
        // TODO: отловить ошибку, если не получилось создать и показать сообщение об этом
    }

    func deleteTasks(taskViewModels: [DeletableItemViewModelType]) {
        var tasksIndexPaths = [IndexPath]()

        for taskViewModel in taskViewModels {
            guard let indexPath = taskViewModel.indexPath else { continue }
            tasksIndexPaths.append(indexPath)
        }

        model.deleteTasksWith(indexPaths: tasksIndexPaths)
    }

    func moveTasksInCurrentList(fromPath: IndexPath, to toPath: IndexPath) {

//        let moveElement = tasks[fromPath.row]
//        tasks[fromPath.row] = tasks[toPath.row]
//        tasks[toPath.row] = moveElement

        // TODO: реализовать перемещение в CoreData
    }

    // MARK: - Update

    func switchTaskFieldIsCompletedWith(indexPath: IndexPath) {
        model.updateAndSwitchIsCompletedFieldWith(indexPath: indexPath)
    }

    func switchTaskFieldIsPriorityWith(indexPath: IndexPath) {
        model.updateAndSwitchIsPriorityFieldWith(indexPath: indexPath)
    }

    func switchTaskFieldInMyDayWith(indexPath: IndexPath) {
        model.switchAndUpdateInMyDayFieldWith(indexPath: indexPath)
    }

    // MARK: - Event handlers

    func handleModelUpdatedEvent(_ event: TasksListModel.UpdatedEvent) {
        switch event {
        case .modelBeginUpdates:
            tableUpdateEventsRelay.accept(.beginUpdates)

        case .modelEndUpdates:
            tableUpdateEventsRelay.accept(.endUpdates)

        case .taskDidCreate(let indexPath):
            tableUpdateEventsRelay.accept(.insertTask(indexPath))

        case .taskDidUpdate(let indexPath, let taskItem):
            tableUpdateEventsRelay.accept(.updateTask(
                indexPath,
                TaskTableViewCellViewModel(task: taskItem)
            ))

        case .taskDidMove(let fromIndexPath, let toIndexPath, let taskItem):
            tableUpdateEventsRelay.accept(.moveTask(
                fromIndexPath,
                toIndexPath,
                TaskTableViewCellViewModel(task: taskItem)
            ))

        case .taskDidDelete(let indexPath):
            tableUpdateEventsRelay.accept(.deleteTask(indexPath))

        case .sectionDidInsert(let sectionIndex):
            tableUpdateEventsRelay.accept(.insertSection(sectionIndex))

        case .sectionDidDelete(let sectionIndex):
            tableUpdateEventsRelay.accept(.deleteSection(sectionIndex))
        }
    }
}

// MARK: - TasksListViewModel.TableUpdateEvent

extension TasksListViewModel {
    enum TableUpdateEvent {
        case beginUpdates
        case endUpdates

        case insertTask(IndexPath)
        case deleteTask(IndexPath)
        case updateTask(IndexPath, TaskTableViewCellViewModel)
        case moveTask(IndexPath, IndexPath, TaskTableViewCellViewModel)

        case insertSection(Int)
        case deleteSection(Int)
    }

}
