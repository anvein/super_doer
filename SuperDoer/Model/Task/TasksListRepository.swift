import Foundation
import CoreData
import RxSwift

final class TasksListRepository: NSObject {

    // MARK: - Services

    private let sectionCDManager: TaskSectionCoreDataManager
    private let taskCDManager: TaskCoreDataManager
    private let coreDataStack: CoreDataStack

    private var fetchedResultsController: NSFetchedResultsController<CDTask>

    // MARK: - State

    let sectionId: UUID?

    private(set) var taskSection: TaskSectionProtocol?
    private(set) var selectedTaskIndexPath: IndexPath?

    // MARK: - Observable

    private let modelUpdatedSubject = PublishSubject<UpdatedEvent>()
    var modelUpdatedObservable: Observable<UpdatedEvent> { modelUpdatedSubject.asObservable() }

    // MARK: - Init

    init(
        sectionId: UUID?,
        sectionCDManager: TaskSectionCoreDataManager,
        taskCDManager: TaskCoreDataManager,
        coreDataStack: CoreDataStack = .shared
    ) {
        self.sectionId = sectionId
        self.sectionCDManager = sectionCDManager
        self.taskCDManager = taskCDManager
        self.coreDataStack = coreDataStack

        if let sectionId {
            taskSection = sectionCDManager.getSection(by: sectionId)
        }

        let fetchRequest: NSFetchRequest<CDTask> = CDTask.fetchRequest()
        fetchRequest.sortDescriptors = [
            .init(key: CDTask.isCompletedKey, ascending: true),
            .init(key: CDTask.createdAtKey, ascending: false),
        ]

        fetchRequest.predicate = Self.buildFilterBySectionPredicate(taskSection: taskSection)

        fetchedResultsController = NSFetchedResultsController(
            fetchRequest: fetchRequest,
            managedObjectContext: coreDataStack.viewContext,
            sectionNameKeyPath: CDTask.isCompletedKey,
            cacheName: nil
        )

        super.init()
        fetchedResultsController.delegate = self
    }

    // MARK: - Initial setup

    func loadTasks() {
        do {
            try fetchedResultsController.performFetch()
        } catch {
            // TODO: обработать нормально
            // уведомить VM -> VC -> показать плашку с ошибкой
            print("Fetch failed")
        }
    }

    // MARK: - Get

    func getSectionTitle() -> String? {
        guard let taskSection = taskSection as? CDTaskCustomSection else { return nil }
        return taskSection.title
    }

    func getSectionsCount() -> Int {
        return fetchedResultsController.sections?.count ?? 0
    }

    func getTasksCountIn(in section: Int) -> Int {
        return fetchedResultsController.sections?[section].numberOfObjects ?? 0
    }

    func getTask(for indexPath: IndexPath) -> TasksListItemEntity {
        let cdTask = getCDTask(at: indexPath)
        return TasksListItemEntity(cdTask: cdTask)
    }

    // MARK: - Modify Task

    func updateTaskField(isCompleted newValue: Bool, for indexPath: IndexPath) {
        let cdTask = getCDTask(at: indexPath)
        taskCDManager.updateField(isCompleted: newValue, task: cdTask)
    }

    func updateTaskField(isPriority newValue: Bool, for indexPath: IndexPath) {
        let cdTask = getCDTask(at: indexPath)
        taskCDManager.updateField(isPriority: newValue, task: cdTask)
    }

    func switchAndUpdateInMyDayFieldWith(indexPath: IndexPath) {
        let cdTask = getCDTask(at: indexPath)
        let newValue = !cdTask.inMyDay
        taskCDManager.updateField(inMyDay: newValue, task: cdTask)
    }

    func deleteTasksWith(indexPaths: [IndexPath]) {
        var cdTasks = [CDTask]()
        for indexPath in indexPaths {
            let cdTask = getCDTask(at: indexPath)
            cdTasks.append(cdTask)
        }
        taskCDManager.delete(tasks: cdTasks)
    }

    func createTaskInCurrentSectionWith(title: String) {
        guard let sectionCustom = taskSection as? CDTaskCustomSection else { return }
        taskCDManager.createWith(title: title, section: sectionCustom)
    }

    // MARK: - Update state

    func setSelectedTaskIndexPath(_ indexPath: IndexPath?) {
        selectedTaskIndexPath = indexPath
    }

    // MARK: - Private methods

    private func getCDTask(at indexPath: IndexPath) -> CDTask {
        return fetchedResultsController.object(at: indexPath)
    }

    private static func buildFilterBySectionPredicate(taskSection: TaskSectionProtocol?) -> NSPredicate? {
        if let cdCustomSection = taskSection as? CDTaskCustomSection {
            return NSPredicate(format: "section == %@", cdCustomSection)
        } else if taskSection is TaskSystemSection {
            return nil
        }

        return nil
    }
}

// MARK: - NSFetchedResultsControllerDelegate

extension TasksListRepository: NSFetchedResultsControllerDelegate {

    func controllerWillChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        modelUpdatedSubject.onNext(.modelBeginUpdates)
    }
    
    func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        modelUpdatedSubject.onNext(.modelEndUpdates)
    }

    func controller(
        _ controller: NSFetchedResultsController<NSFetchRequestResult>,
        didChange anObject: Any,
        at indexPath: IndexPath?,
        for type: NSFetchedResultsChangeType,
        newIndexPath: IndexPath?
    ) {
        switch type {
        case .insert:
            if let newIndexPath {
                modelUpdatedSubject.onNext(.taskDidCreate(indexPath: newIndexPath))
            }

        case .delete:
            if let indexPath {
                modelUpdatedSubject.onNext(.taskDidDelete(indexPath: indexPath))
            }

        case .update:
            if let indexPath,
               let cdTask = anObject as? CDTask{
                let taskItem = TasksListItemEntity(cdTask: cdTask)
                modelUpdatedSubject.onNext(.taskDidUpdate(indexPath: indexPath, taskItem: taskItem))
            }

        case .move:
            if let indexPath, let newIndexPath,
               let cdTask = anObject as? CDTask {
                let taskItem = TasksListItemEntity(cdTask: cdTask)
                modelUpdatedSubject.onNext(.taskDidMove(
                    fromIndexPath: indexPath,
                    toIndexPath: newIndexPath,
                    taskItem: taskItem
                ))
            }

        @unknown default:
            break
        }
    }

    func controller(
        _ controller: NSFetchedResultsController<NSFetchRequestResult>,
        didChange sectionInfo: NSFetchedResultsSectionInfo,
        atSectionIndex sectionIndex: Int,
        for type: NSFetchedResultsChangeType
    ) {
        switch type {
        case .insert:
            modelUpdatedSubject.onNext(.sectionDidInsert(sectionIndex: sectionIndex))

        case .delete:
            modelUpdatedSubject.onNext(.sectionDidDelete(sectionIndex: sectionIndex))

        default:
            break
        }
    }
}

// MARK: - UpdatedEvent

extension TasksListRepository {
    enum UpdatedEvent {
        case modelBeginUpdates
        case modelEndUpdates

        case taskDidCreate(indexPath: IndexPath)
        case taskDidUpdate(indexPath: IndexPath, taskItem: TasksListItemEntity)
        case taskDidMove(fromIndexPath: IndexPath, toIndexPath: IndexPath, taskItem: TasksListItemEntity)
        case taskDidDelete(indexPath: IndexPath)

        case sectionDidInsert(sectionIndex: Int)
        case sectionDidDelete(sectionIndex: Int)
    }
}
