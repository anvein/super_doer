import CoreData
import Foundation
import RxSwift

final class TasksListRepository: NSObject {

    enum UpdateActionTaskField {
        case isCompleted(Bool)
        case isPriority(Bool)
        case toggleInMyDay
    }

    // MARK: - Services

    private let sectionCDSource: TaskSectionCoreDataSource
    private let taskCDSource: TaskCoreDataSource
    private let coreDataStack: CoreDataStack

    private lazy var fetchedResultsController: NSFetchedResultsController<CDTask> = buildFetchResultsController(
        section: nil
    )

    private var context: NSManagedObjectContext {
        coreDataStack.viewContext
    }

    // MARK: - Observable

    private let modelUpdatedSubject = PublishSubject<UpdatedEvent>()
    var modelUpdatedObservable: Observable<UpdatedEvent> { modelUpdatedSubject.asObservable() }

    // MARK: - Init

    init(
        sectionCDManager: TaskSectionCoreDataSource,
        taskCDManager: TaskCoreDataSource,
        coreDataStack: CoreDataStack
    ) {
        self.sectionCDSource = sectionCDManager
        self.taskCDSource = taskCDManager
        self.coreDataStack = coreDataStack
        super.init()
    }

    // MARK: - Initial setup

    func setSection(_ section: TasksListSection) {
        fetchedResultsController = buildFetchResultsController(section: section)
    }

    private func buildFetchResultsController(section: TasksListSection?) -> NSFetchedResultsController<CDTask> {
        let fetchRequest: NSFetchRequest<CDTask> = CDTask.fetchRequest()
        fetchRequest.sortDescriptors = [
            .init(key: CDTask.isCompletedKey, ascending: true),
            .init(key: CDTask.createdAtKey, ascending: false),
        ]

        switch section {
        case .custom(let sectionId):
            fetchRequest.predicate = NSPredicate(format: "section.id == %@", sectionId as CVarArg)

        case .system:
            break

        default:
            break
        }

        fetchedResultsController = NSFetchedResultsController(
            fetchRequest: fetchRequest,
            managedObjectContext: context,
            sectionNameKeyPath: CDTask.isCompletedKey,
            cacheName: nil
        )
        fetchedResultsController.delegate = self

        return fetchedResultsController
    }

    func loadTasks() throws {
        do {
            try fetchedResultsController.performFetch()
        } catch {
            throw TasksListRepositoryError.loadDataFailed
        }
    }

    // MARK: - Get

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

    func getTaskId(for indexPath: IndexPath) -> UUID? {
        let cdTask = getCDTask(at: indexPath)
        return cdTask.id
    }

    // MARK: - Modify Task

    func deleteTasksWith(indexPaths: [IndexPath]) throws {
        var cdTasks = [CDTask]()
        for indexPath in indexPaths {
            let cdTask = getCDTask(at: indexPath)
            cdTasks.append(cdTask)
        }
        taskCDSource.delete(tasks: cdTasks)

        do {
            try context.save()
        } catch {
            throw TasksListRepositoryError.failedDeleteTasks(error: error)
        }
    }

    // MARK: - Helpers

    private func getCDTask(at indexPath: IndexPath) -> CDTask {
        return fetchedResultsController.object(at: indexPath)
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
            if let indexPath, let cdTask = anObject as? CDTask {
                let taskItem = TasksListItemEntity(cdTask: cdTask)
                modelUpdatedSubject.onNext(.taskDidUpdate(indexPath: indexPath, taskItem: taskItem))
            }

        case .move:
            if let indexPath, let newIndexPath, let cdTask = anObject as? CDTask {
                let taskItem = TasksListItemEntity(cdTask: cdTask)
                modelUpdatedSubject.onNext(
                    .taskDidMove(fromIndexPath: indexPath, toIndexPath: newIndexPath, taskItem: taskItem)
                )
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
