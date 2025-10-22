import Foundation
import CoreData
import RxSwift

final class TasksListModel: NSObject {

    // MARK: - Services

    private let taskCDManager: TaskCoreDataManager
    private let coreDataStack: CoreDataStack

    // MARK: - State

    private(set) var taskSection: TaskSectionProtocol?
    private(set) var selectedTaskIndexPath: IndexPath?

    // MARK: - Observable

    private let modelUpdatedSubject = PublishSubject<UpdatedEvent>()
    var modelUpdatedObservable: Observable<UpdatedEvent> { modelUpdatedSubject.asObservable() }

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
            // уведомить VM -> VC -> показать плашку с ошибкой
            print("Fetch failed")
        }
    }

    // MARK: - Get

    func getSectionTitle() -> String? {
        guard let taskSection = taskSection as? CDTaskSectionCustom else { return nil }
        return taskSection.title
    }

//    func getTaskIdFor(indexPath: IndexPath) -> UUID? {
//        return getCDTask(at: indexPath).id
//    }

    func getSectionsCount() -> Int {
        return fetchedResultsController.sections?.count ?? 0
    }

    func getTasksCountIn(in section: Int) -> Int {
        return fetchedResultsController.sections?[section].numberOfObjects ?? 0
    }

    func getTask(for indexPath: IndexPath) -> TasksListItemModel {
        let cdTask = getCDTask(at: indexPath)
        return TasksListItemModel(cdTask: cdTask)
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

    func createTaskInCurrentSectionWith(title: String) {
        guard let sectionCustom = taskSection as? CDTaskSectionCustom else { return }
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
        if let cdCustomSection = taskSection as? CDTaskSectionCustom {
            return NSPredicate(format: "section == %@", cdCustomSection)
        } else if taskSection is TaskSectionSystem {
            return nil
        }

        return nil
    }
}

// MARK: - NSFetchedResultsControllerDelegate

extension TasksListModel: NSFetchedResultsControllerDelegate {

    func controllerWillChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        modelUpdatedSubject.onNext(.modelBeginUpdates)
    }
    
    func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        modelUpdatedSubject.onNext(.modelEndUpdates)
    }

    func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>, didChange anObject: Any, at indexPath: IndexPath?, for type: NSFetchedResultsChangeType, newIndexPath: IndexPath?) {
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
                let taskItem = TasksListItemModel(cdTask: cdTask)
                modelUpdatedSubject.onNext(.taskDidUpdate(indexPath: indexPath, taskItem: taskItem))
            }

        case .move:
            if let indexPath, let newIndexPath,
               let cdTask = anObject as? CDTask {
                let taskItem = TasksListItemModel(cdTask: cdTask)
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

    func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>, didChange sectionInfo: NSFetchedResultsSectionInfo, atSectionIndex sectionIndex: Int, for type: NSFetchedResultsChangeType) {
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

extension TasksListModel {
    enum UpdatedEvent {
        case modelBeginUpdates
        case modelEndUpdates

        case taskDidCreate(indexPath: IndexPath)
        case taskDidUpdate(indexPath: IndexPath, taskItem: TasksListItemModel)
        case taskDidMove(fromIndexPath: IndexPath, toIndexPath: IndexPath, taskItem: TasksListItemModel)
        case taskDidDelete(indexPath: IndexPath)

        case sectionDidInsert(sectionIndex: Int)
        case sectionDidDelete(sectionIndex: Int)
    }
}
