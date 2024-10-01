
import CoreData

class TaskCoreDataManager {

    private let coreDataStack: CoreDataStack

    // MARK: - Init

    init(coreDataStack: CoreDataStack = .shared) {
        self.coreDataStack = coreDataStack
    }

    // MARK: - Get

    func getTaskBy(id: UUID) -> CDTask? {
        let fetchRequest = CDTask.fetchRequest()
        fetchRequest.predicate = NSPredicate(format: "\(CDTask.idKey) == %@", id.uuidString)

        do {
            return try coreDataStack.context.fetch(fetchRequest).first
        } catch let error as NSError {
            fatalError("getTaskBy id error - \(error)")
        }
    }

    func getAllTasks() -> [CDTask] {
        let fetchRequest = NSFetchRequest<CDTask>(entityName: CDTask.entityName)
        
        do {
            let tasks = try coreDataStack.context.fetch(fetchRequest)
            return tasks
        } catch let error as NSError {
            fatalError("getAllTasks error - \(error)")
        }
    }
    
    func getTasks(for taskSection: CDTaskSectionCustom?) -> [CDTask] {
        let fetchRequest = CDTask.fetchRequest()
        
        if let safeTaskSection = taskSection {
            let listPredicate = NSPredicate(format: "section == %@", safeTaskSection)
            fetchRequest.predicate = listPredicate
        }
    
        do {
            return try coreDataStack.context.fetch(fetchRequest)
        } catch let error as NSError {
            fatalError("getTasks for custom section error - \(error)")
        }
    }

    
    // MARK: - Update

    func updateField(title: String, task: CDTask) {
        task.title = title
        coreDataStack.saveContext()
    }
    
    func updateField(isCompleted: Bool, task: CDTask) {
        task.isCompleted = isCompleted
        coreDataStack.saveContext()
    }
    
    func updateField(isPriority: Bool, task: CDTask) {
        task.isPriority = isPriority
        coreDataStack.saveContext()
    }
    
    func updateField(inMyDay: Bool, task: CDTask) {
        task.inMyDay = inMyDay
        coreDataStack.saveContext()
    }
    
    func updateField(deadlineDate: Date?, task: CDTask) {
        task.deadlineDate = deadlineDate
        coreDataStack.saveContext()
    }
    
    func updateField(reminderDateTime: Date?, task: CDTask) {
        task.reminderDateTime = reminderDateTime
        coreDataStack.saveContext()
    }
    
    func updateField(repeatPeriod: String?, task: CDTask) {
        task.repeatPeriod = repeatPeriod
        coreDataStack.saveContext()
    }
    
    func updateFields(descriptionText: String?, descriptionUpdatedAt: Date, task: CDTask) {
        task.descriptionText = descriptionText
        task.descriptionUpdatedAt = descriptionUpdatedAt
        
        coreDataStack.saveContext()
    }
    
    
    // MARK: - Insert

    @discardableResult
    func createWith(title: String, section: CDTaskSectionCustom? = nil) -> CDTask {
        let task = CDTask(context: coreDataStack.context)
        task.id = UUID()
        task.title = title
        task.section = section
        task.createdAt = Date()

        coreDataStack.saveContext()

        return task
    }
    
    
    // MARK: - Delete

    func delete(tasks: [CDTask]) {
        for task in tasks {
            coreDataStack.context.delete(task)
        }

        coreDataStack.saveContext()
    }

    func delete(task: CDTask) {
        coreDataStack.context.delete(task)
        coreDataStack.saveContext()
    }

}
