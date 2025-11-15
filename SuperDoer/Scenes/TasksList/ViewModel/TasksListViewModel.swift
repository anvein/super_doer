import Foundation
import RxSwift
import RxCocoa

class TasksListViewModel: TasksListViewModelType, TasksListNavigationEmittable, TasksListCoordinatorResultHandler {

    private let repository: TasksListRepository
    private let sectionCDManager: TaskSectionCoreDataManager

    // MARK: - State / Rx

    private let disposeBag = DisposeBag()

    private let sectionTitleRelay = BehaviorRelay<String>(value: "")
    var sectionTitleDriver: Driver<String> { sectionTitleRelay.asDriver() }

    private let tableUpdateEventsRelay = PublishRelay<TaskListTableUpdateEvent>()
    var tableUpdateEventsSignal: Signal<TaskListTableUpdateEvent> { tableUpdateEventsRelay.asSignal() }

    private let errorMessageRelay = PublishRelay<String>()
    var errorMessageSignal: Signal<String> { errorMessageRelay.asSignal() }

    // MARK: - Navigation

    var coordinatorResult = PublishRelay<TasksListCoordinatorResult>()

    private let navigationEventRelay = PublishRelay<TasksListNavigationEvent>()
    var navigationEvent: Signal<TasksListNavigationEvent> { navigationEventRelay.asSignal() }

    // MARK: - Init

    init(
        repository: TasksListRepository,
        sectionCDManager: TaskSectionCoreDataManager
    ) {
        self.repository = repository
        self.sectionCDManager = sectionCDManager

        sectionTitleRelay.accept(repository.getSectionTitle() ?? "")

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

        // C -> VM
        coordinatorResult
            .subscribe { [weak self] event in
                switch event {
                case .onDeleteTasksConfirmed(let deletableTasks):
                    self?.handleConfirmDelete(deletableTasks)

                case .onDeleteTasksCanceled:
                    return
                }
            }
            .disposed(by: disposeBag)
    }

    // MARK: - Get data

    func getSectionsCount() -> Int {
        return repository.getSectionsCount()
    }

    func getTasksCountInSection(with index: Int) -> Int {
        return repository.getTasksCountIn(in: index)
    }

    func getTableCellVM(for indexPath: IndexPath) -> TaskTableCellViewModelType {
        let task = repository.getTask(for: indexPath)
        return TaskTableViewCellViewModel(task: task)
    }

    // MARK: - UI Actions

    func needLoadInitialData() {
        repository.loadTasks()
    }

    func didTapOpenTask(with indexPath: IndexPath) {
        let task = repository.getTask(for: indexPath)

        guard let taskId = task.id else { return }
        navigationEventRelay.accept(
            .openTaskDetail(taskId: taskId)
        )
    }

    func didTapDeleteTask(with indexPath: IndexPath) {
        let task = repository.getTask(for: indexPath)
        let deletableViewModel = TaskDeletableViewModel(task: task, indexPath: indexPath)

        navigationEventRelay.accept(
            .openDeleteTasksConfirmation([deletableViewModel])
        )
    }

    func didTapDeleteTasks(with indexPaths: [IndexPath]) {
        let deletableTasksVMs = indexPaths.map { indexPath in
            return TaskDeletableViewModel(
                task: repository.getTask(for: indexPath),
                indexPath: indexPath
            )
        }

        navigationEventRelay.accept(
            .openDeleteTasksConfirmation(deletableTasksVMs)
        )
    }

    func didToggleTaskInMyDay(with indexPath: IndexPath) {
        repository.switchAndUpdateInMyDayFieldWith(indexPath: indexPath)
    }

    func didTapTaskIsCompleted(_ newValue: Bool, with indexPath: IndexPath) {
        repository.updateTaskField(isCompleted: newValue, for: indexPath)
    }

    func didTapTaskIsPriority(_ newValue: Bool, with indexPath: IndexPath) {
        repository.updateTaskField(isPriority: newValue, for: indexPath)
    }

    func didTapCreateTaskInCurrentSection(with data: TaskCreateData) {
        repository.createTaskInCurrentSectionWith(title: data.title)
    }

    func didMoveEndTasksInCurrentSection(from: IndexPath, to toPath: IndexPath) {
//        let moveElement = tasks[fromPath.row]
//        tasks[fromPath.row] = tasks[toPath.row]
//        tasks[toPath.row] = moveElement

        // TODO: реализовать перемещение в CoreData
    }

    func didConfirmRenameSectionTitle(_ title: String) {
        guard let titlePrepared = title.normalizedWhitespaceOrNil(),
              let section = repository.taskSection as? CDTaskCustomSection else {
            sectionTitleRelay.accept(repository.getSectionTitle() ?? "")
            errorMessageRelay.accept("Не удалось изменить название")

            return
        }

        sectionCDManager.updateCustomSectionField(title: titlePrepared, section: section)
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

    private func handleConfirmDelete(_ deletableViewModels: [TaskDeletableViewModel]) {
        var tasksIndexPaths = [IndexPath]()

        for deletableVM in deletableViewModels {
            guard let indexPath = deletableVM.indexPath else { continue }
            tasksIndexPaths.append(indexPath)
        }

        repository.deleteTasksWith(indexPaths: tasksIndexPaths)
    }

}
