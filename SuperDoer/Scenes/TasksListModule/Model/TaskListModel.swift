
import Foundation
import CoreData

final class TaskListModel: NSObject {
    
    // MARK: - Services

    private let taskCDManager: TaskCoreDataManager
    private let coreDataStack: CoreDataStack

    weak var delegate: TaskListModelDelegate?

    // MARK: - State

    private(set) var taskSection: TaskSectionProtocol?
    private(set) var selectedTaskIndexPath: IndexPath?

    // MARK: -

    private var fetchedResultsController: NSFetchedResultsController<CDTask>

    // MARK: - Init

    init(
        taskSection: TaskSectionProtocol?,
        taskCDManager: TaskCoreDataManager,
        coreDataStack: CoreDataStack = .shared
    ) {
        self.taskSection = taskSection
        self.taskCDManager = taskCDManager
        self.coreDataStack = coreDataStack

        let fetchRequest: NSFetchRequest<CDTask> = CDTask.fetchRequest()
        fetchRequest.sortDescriptors = [
            .init(key: CDTask.isCompletedKey, ascending: true),
            .init(key: CDTask.createdAtKey, ascending: false),
        ]

        fetchRequest.predicate = Self.buildFilterBySectionPredicate(taskSection: taskSection)

        fetchedResultsController = NSFetchedResultsController(
            fetchRequest: fetchRequest,
            managedObjectContext: coreDataStack.context,
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
            print("Fetch failed")
        }
    }

    // MARK: - Get

    func getTaskIdFor(indexPath: IndexPath) -> UUID? {
        return getCDTask(at: indexPath).id
    }

    func getSectionsCount() -> Int {
        return fetchedResultsController.sections?.count ?? 0
    }

    func getTasksCountIn(in section: Int) -> Int {
        return fetchedResultsController.sections?[section].numberOfObjects ?? 0
    }

    func getTask(for indexPath: IndexPath) -> TaskListItem {
        let cdTask = getCDTask(at: indexPath)
        return TaskListItem(cdTask: cdTask)
    }

    // MARK: - Modify Task

    func updateAndSwitchIsCompletedFieldWith(indexPath: IndexPath) {
        let cdTask = getCDTask(at: indexPath)
        let newValue = !cdTask.isCompleted
        taskCDManager.updateField(isCompleted: newValue, task: cdTask)
    }

    func updateAndSwitchIsPriorityFieldWith(indexPath: IndexPath) {
        let cdTask = getCDTask(at: indexPath)
        let newValue = !cdTask.isPriority
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

    func createTaskWith(title: String, section: CDTaskSectionCustom) {
        taskCDManager.createWith(title: title, section: section)
    }

    // MARK: - Update state

    func setSelectedTaskIndexPath(_ indexPath: IndexPath?) {
        selectedTaskIndexPath = indexPath
    }

}

// MARK: - Private methods

private extension TaskListModel {
    func getCDTask(at indexPath: IndexPath) -> CDTask {
        return fetchedResultsController.object(at: indexPath)
    }

    static func buildFilterBySectionPredicate(taskSection: TaskSectionProtocol?) -> NSPredicate? {
        if let cdCustomSection = taskSection as? CDTaskSectionCustom {
            return NSPredicate(format: "section == %@", cdCustomSection)
        } else if let systemSection = taskSection as? TaskSectionSystem {
            return nil
        }

        return nil
    }
}

// MARK: - NSFetchedResultsControllerDelegate

extension TaskListModel: NSFetchedResultsControllerDelegate {

    func controllerWillChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        delegate?.taskListModelBeginUpdates()
    }
    
    func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        delegate?.taskListModelEndUpdates()
    }

    func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>, didChange anObject: Any, at indexPath: IndexPath?, for type: NSFetchedResultsChangeType, newIndexPath: IndexPath?) {
        switch type {
        case .insert:
            if let newIndexPath {
                delegate?.taskListModelTaskDidCreate(indexPath: newIndexPath)
            }
        case .delete:
            if let indexPath {
                delegate?.taskListModelTaskDidDelete(indexPath: indexPath)
            }
        case .update:
            if let indexPath,
               let cdTask = anObject as? CDTask{
                let taskItem = TaskListItem(cdTask: cdTask)
                delegate?.taskListModelTaskDidUpdate(in: indexPath, taskItem: taskItem)
            }

        case .move:
            if let indexPath, let newIndexPath,
               let cdTask = anObject as? CDTask {
               let taskItem = TaskListItem(cdTask: cdTask)
                delegate?.taskListModelTaskDidMove(
                    fromIndexPath: indexPath,
                    toIndexPath: newIndexPath,
                    taskItem: taskItem
                )
            }

        @unknown default:
            break
        }
    }

    func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>, didChange sectionInfo: NSFetchedResultsSectionInfo, atSectionIndex sectionIndex: Int, for type: NSFetchedResultsChangeType) {
        switch type {
        case .insert:
            delegate?.taskListModelSectionDidInsert(sectionIndex: sectionIndex)
        case .delete:
            delegate?.taskListModelSectionDidDelete(sectionIndex: sectionIndex)
        default:
            break
        }
    }
}

