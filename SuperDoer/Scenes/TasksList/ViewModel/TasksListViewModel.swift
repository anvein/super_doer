import Foundation
import RxCocoa
import RxSwift

class TasksListViewModel: TasksListViewModelType, TasksListNavigationEmittable, TasksListCoordinatorResultHandler {

    private let listRepository: TasksListRepository
    private let sectionRepository: TaskSectionRepository
    private let taskRepository: TaskRepository

    // MARK: - State / Rx

    private let section: TasksListSection

    private let disposeBag = DisposeBag()

    private let sectionTitleRelay = BehaviorRelay<String>(value: "")
    var sectionTitleDriver: Driver<String> { sectionTitleRelay.asDriver() }

    private let tableUpdateEventsRelay = PublishRelay<TaskListTableUpdateEvent>()
    var tableUpdateEventsSignal: Signal<TaskListTableUpdateEvent> { tableUpdateEventsRelay.asSignal() }

    private let errorMessageRelay = PublishRelay<String>()
    var errorMessageSignal: Signal<String> { errorMessageRelay.asSignal() }

    private let customSectionRelay = BehaviorRelay<TaskCustomSection?>(value: nil)

    // MARK: - Navigation

    var coordinatorResult = PublishRelay<TasksListCoordinatorResult>()

    private let navigationEventRelay = PublishRelay<TasksListNavigationEvent>()
    var navigationEvent: Signal<TasksListNavigationEvent> { navigationEventRelay.asSignal() }

    // MARK: - Init

    init(
        section: TasksListSection,
        listRepository: TasksListRepository,
        sectionRepository: TaskSectionRepository,
        taskRepository: TaskRepository
    ) {
        self.section = section
        self.listRepository = listRepository
        self.sectionRepository = sectionRepository
        self.taskRepository = taskRepository

        listRepository.setSection(section)
        setupBindings()
    }

    // MARK: - Setup

    private func setupBindings() {
        // M -> VM
        listRepository.modelUpdatedObservable
            .scan(
                (
                    nil as TasksListRepository.UpdatedEvent?,
                    nil as TasksListRepository.UpdatedEvent?
                )
            ) { accumulator, current in
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
        return listRepository.getSectionsCount()
    }

    func getTasksCountInSection(with index: Int) -> Int {
        return listRepository.getTasksCountIn(in: index)
    }

    func getTableCellVM(for indexPath: IndexPath) -> TaskTableCellViewModelType {
        let task = listRepository.getTask(for: indexPath)
        return TaskTableViewCellViewModel(task: task)
    }

    // MARK: - UI Actions

    func needLoadInitialData() {
        do {
            try listRepository.loadTasks()

            switch section {
            case .custom(let sectionId):
                let customSection = try sectionRepository.getSection(by: sectionId)
                sectionTitleRelay.accept(customSection?.fullTitle ?? "")

            case .system(let taskSystemSection):
                sectionTitleRelay.accept(taskSystemSection.fullTitle)
            }
        } catch {
            // показать ошибку
        }
    }

    func didTapOpenTask(with indexPath: IndexPath) {
        let task = listRepository.getTask(for: indexPath)

        guard let taskId = task.id else { return }
        navigationEventRelay.accept(
            .openTaskDetail(taskId: taskId)
        )
    }

    func didTapDeleteTask(with indexPath: IndexPath) {
        let task = listRepository.getTask(for: indexPath)
        let deletableViewModel = TaskDeletableViewModel(task: task, indexPath: indexPath)

        navigationEventRelay.accept(
            .openDeleteTasksConfirmation([deletableViewModel])
        )
    }

    func didTapDeleteTasks(with indexPaths: [IndexPath]) {
        let deletableTasksVMs = indexPaths.map { indexPath in
            return TaskDeletableViewModel(
                task: listRepository.getTask(for: indexPath),
                indexPath: indexPath
            )
        }

        navigationEventRelay.accept(
            .openDeleteTasksConfirmation(deletableTasksVMs)
        )
    }

    func didToggleTaskInMyDay(with indexPath: IndexPath) {
        guard let taskId = listRepository.getTaskId(for: indexPath) else {
            // показать ошибку: не удалось обновить задачу
            // откатить изменения в UI
            return
        }

        do {
            try taskRepository.updateField(.inMyDayToggle, taskId: taskId)
        } catch {
            // показать ошибку: не удалось обновить задачу
            // откатить изменения в UI
        }
    }

    func didTapTaskIsCompleted(_ newValue: Bool, with indexPath: IndexPath) {
        guard let taskId = listRepository.getTaskId(for: indexPath) else {
            // показать ошибку: не удалось обновить задачу
            // откатить изменения в UI
            return
        }

        do {
            try taskRepository.updateField(.isCompleted(newValue), taskId: taskId)
        } catch {
            // показать ошибку: не удалось обновить задачу
            // откатить изменения в UI
        }
    }

    func didTapTaskIsPriority(_ newValue: Bool, with indexPath: IndexPath) {
        guard let taskId = listRepository.getTaskId(for: indexPath) else {
            // показать ошибку: не удалось обновить задачу
            // откатить изменения в UI
            return
        }

        do {
            try taskRepository.updateField(.isPriority(newValue), taskId: taskId)
        } catch {
            // показать ошибку
        }
    }

    func didTapCreateTaskInCurrentSection(with data: TaskCreateData) {
        do {
            try taskRepository.createTask(with: data.title, in: section)
        } catch {
            // показать ошибку
        }
    }

    func didMoveEndTasksInCurrentSection(from: IndexPath, to toPath: IndexPath) {
        //        let moveElement = tasks[fromPath.row]
        //        tasks[fromPath.row] = tasks[toPath.row]
        //        tasks[toPath.row] = moveElement

        // TODO: реализовать перемещение в CoreData
    }

    func didConfirmRenameSectionTitle(_ title: String) {
        guard case .custom(let customSectionId) = section else { return }

        guard let titlePrepared = title.normalizedWhitespaceOrNil() else {
            sectionTitleRelay.accept(sectionTitleRelay.value)
            return
        }

        do {
            let customSection = try sectionRepository.updateCustomSectionField(
                title: titlePrepared,
                with: customSectionId
            )
            sectionTitleRelay.accept(customSection.fullTitle)
        } catch {
            sectionTitleRelay.accept(sectionTitleRelay.value)
            errorMessageRelay.accept("Не удалось изменить название")
        }
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
            tableUpdateEventsRelay.accept(
                .updateTask(
                    indexPath,
                    TaskTableViewCellViewModel(task: taskItem)
                )
            )

        case (.sectionDidDelete(_), .taskDidMove(let fromIndexPath, let toIndexPath, _)),
            (.sectionDidInsert(_), .taskDidMove(let fromIndexPath, let toIndexPath, _)):

            tableUpdateEventsRelay.accept(.deleteTask(fromIndexPath, withEditSection: true))
            tableUpdateEventsRelay.accept(.insertTask(toIndexPath, withEditSection: true))

        case (_, .taskDidMove(let fromIndexPath, let toIndexPath, let taskItem)):
            tableUpdateEventsRelay.accept(
                .moveTask(
                    fromIndexPath,
                    toIndexPath,
                    TaskTableViewCellViewModel(task: taskItem)
                )
            )

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

        do {
            try listRepository.deleteTasksWith(indexPaths: tasksIndexPaths)
        } catch {
            // показать ошибку: не удалось удалить задачи
        }
    }

}
