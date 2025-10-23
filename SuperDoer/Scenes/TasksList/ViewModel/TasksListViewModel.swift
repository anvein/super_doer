import Foundation
import RxSwift
import RxCocoa

class TasksListViewModel: TasksListViewModelType {

    private let repository: TasksListRepository

    // MARK: - State / Rx

    private let disposeBag = DisposeBag()

    private let sectionTitleRelay = BehaviorRelay<String>(value: "")
    var sectionTitleDriver: Driver<String> { sectionTitleRelay.asDriver() }

    private let tableUpdateEventsRelay = PublishRelay<TaskListTableUpdateEvent>()
    var tableUpdateEventsSignal: Signal<TaskListTableUpdateEvent> { tableUpdateEventsRelay.asSignal() }

    // MARK: - Init

    init(model: TasksListRepository) {
        self.repository = model

        sectionTitleRelay.accept(model.getSectionTitle() ?? "")

        setupBindings()
    }

    // MARK: - Setup

    private func setupBindings() {
        // M -> VM
        repository.modelUpdatedObservable
            .scan((
                nil as TasksListRepository.UpdatedEvent?,
                nil as TasksListRepository.UpdatedEvent?
            )) { accumulator, current in
                (accumulator.1, current)
            }
            .subscribe(onNext: { [weak self] prevEvent, newEvent in
                self?.handleModelUpdatedEvent(prev: prevEvent, new: newEvent)
            })
            .disposed(by: disposeBag)
    }

    // MARK: -

    func loadInitialData() {
        repository.loadTasks()
    }

    // MARK: get data for VC methods

    func getSectionsCount() -> Int {
        return repository.getSectionsCount()
    }

    func getTasksCountInSection(with index: Int) -> Int {
        return repository.getTasksCountIn(in: index)
    }

    func getTasksTableViewCellVM(forIndexPath indexPath: IndexPath) -> TaskTableViewCellViewModelType  {
        let task = repository.getTask(for: indexPath)
        return TaskTableViewCellViewModel(task: task)
    }

    func getTaskDetailViewModel(for indexPath: IndexPath) -> TaskDetailViewModel? {
        let selectedTask = repository.getTask(for: indexPath)
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
                task: repository.getTask(for: indexPath),
                indexPath: indexPath
            )
            viewModels.append(viewModel)
        }

        return viewModels
    }

    // MARK: model manipulation methods

    func createNewTaskInCurrentSection(with data: TaskCreateData) {
        repository.createTaskInCurrentSectionWith(title: data.title)
        // TODO: отловить ошибку, если не получилось создать и показать сообщение об этом
    }

    func deleteTasks(taskViewModels: [DeletableItemViewModelType]) {
        var tasksIndexPaths = [IndexPath]()

        for taskViewModel in taskViewModels {
            guard let indexPath = taskViewModel.indexPath else { continue }
            tasksIndexPaths.append(indexPath)
        }

        repository.deleteTasksWith(indexPaths: tasksIndexPaths)
    }

    func moveTasksInCurrentList(fromPath: IndexPath, to toPath: IndexPath) {

//        let moveElement = tasks[fromPath.row]
//        tasks[fromPath.row] = tasks[toPath.row]
//        tasks[toPath.row] = moveElement

        // TODO: реализовать перемещение в CoreData
    }

    // MARK: - Update

    func switchTaskFieldIsCompletedWith(indexPath: IndexPath) {
        repository.updateAndSwitchIsCompletedFieldWith(indexPath: indexPath)
    }

    func switchTaskFieldIsPriorityWith(indexPath: IndexPath) {
        repository.updateAndSwitchIsPriorityFieldWith(indexPath: indexPath)
    }

    func switchTaskFieldInMyDayWith(indexPath: IndexPath) {
        repository.switchAndUpdateInMyDayFieldWith(indexPath: indexPath)
    }

    // MARK: - Event handlers

    private func handleModelUpdatedEvent(
        prev prevEvent: TasksListRepository.UpdatedEvent?,
        new currentEvent: TasksListRepository.UpdatedEvent?
    ) {
        switch (prevEvent, currentEvent) {
        case (_, .modelBeginUpdates):
            tableUpdateEventsRelay.accept(.beginUpdates)

        case (_, .modelEndUpdates):
            tableUpdateEventsRelay.accept(.endUpdates)

        case (_, .taskDidCreate(let indexPath)):
            tableUpdateEventsRelay.accept(.insertTask(indexPath))

        case (_, .taskDidUpdate(let indexPath, let taskItem)):
            tableUpdateEventsRelay.accept(.updateTask(
                indexPath,
                TaskTableViewCellViewModel(task: taskItem)
            ))

        case (.sectionDidDelete(_), .taskDidMove(let fromIndexPath, let toIndexPath, _)),
             (.sectionDidInsert(_), .taskDidMove(let fromIndexPath, let toIndexPath, _)):

            tableUpdateEventsRelay.accept(.deleteTask(fromIndexPath, withEditSection: true))
            tableUpdateEventsRelay.accept(.insertTask(toIndexPath, withEditSection: true))

        case (_, .taskDidMove(let fromIndexPath, let toIndexPath, let taskItem)):
            tableUpdateEventsRelay.accept(.moveTask(
                fromIndexPath,
                toIndexPath,
                TaskTableViewCellViewModel(task: taskItem)
            ))

        case (_, .taskDidDelete(let indexPath)):
            tableUpdateEventsRelay.accept(.deleteTask(indexPath))

        case (_, .sectionDidInsert(let sectionIndex)):
            tableUpdateEventsRelay.accept(.insertSection(sectionIndex))

        case (_, .sectionDidDelete(let sectionIndex)):
            tableUpdateEventsRelay.accept(.deleteSection(sectionIndex))

        default:
            break
        }
    }
}
