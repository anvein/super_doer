import Foundation
import RxSwift
import RxCocoa

class TasksListViewModel: TasksListViewModelType {

    private let model: TasksListModel

    // MARK: - State / Rx

    private let disposeBag = DisposeBag()

    private let sectionTitleRelay = BehaviorRelay<String>(value: "")
    var sectionTitleDriver: Driver<String> { sectionTitleRelay.asDriver() }

    private let tableUpdateEventsRelay = PublishRelay<TaskListTableUpdateEvent>()
    var tableUpdateEventsSignal: Signal<TaskListTableUpdateEvent> { tableUpdateEventsRelay.asSignal() }

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

    func loadInitialData() {
        model.loadTasks()
    }

    // MARK: get data for VC methods

    func getSectionsCount() -> Int {
        return model.getSectionsCount()
    }

    func getTasksCountInSection(with index: Int) -> Int {
        return model.getTasksCountIn(in: index)
    }

    func getTasksTableViewCellVM(forIndexPath indexPath: IndexPath) -> TaskTableViewCellViewModelType  {
        let task = model.getTask(for: indexPath)
        return TaskTableViewCellViewModel(task: task)
    }

    func getTaskDetailViewModel(for indexPath: IndexPath) -> TaskDetailViewModel? {
        let selectedTask = model.getTask(for: indexPath)
        guard let taskId = selectedTask.id else { return nil }

        return TaskDetailViewModel(
            taskId,
            taskEm: DIContainer.shared.resolve(TaskCoreDataManager.self)!,
            taskFileEm: DIContainer.shared.resolve(TaskFileEntityManager.self)!
        )
    }

    func getTasksDeletableViewModels(for indexPaths: [IndexPath]) -> [TaskDeletableViewModel] {
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

    func createNewTaskInCurrentSection(with data: TaskCreateData) {
        model.createTaskInCurrentSectionWith(title: data.title)
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
