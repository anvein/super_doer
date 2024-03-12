
import UIKit
import CoreData

class TaskEntityManager: EntityManager {
    // MARK: get
    func getAllTasks() -> [CDTask] {
        let fetchRequest = NSFetchRequest<CDTask>(entityName: CDTask.entityName)
        
        do {
            let tasks = try getContext().fetch(fetchRequest)
            return tasks
        } catch let error as NSError {
            fatalError("getAllTasks error - \(error)")
        }
    }
    
    func getTasks(for taskSection: TaskSectionCustom?) -> [CDTask] {
        let fetchRequest = CDTask.fetchRequest()
        
        if let safeTaskSection = taskSection {
            // TODO: избавиться от force unwrapping
            let listPredicate = NSPredicate(format: "section == %@", safeTaskSection)
            fetchRequest.predicate = listPredicate
        }
    
        do {
            let tasks = try getContext().fetch(fetchRequest)
            return tasks
        } catch let error as NSError {
            fatalError("getTasks for custom section error - \(error)")
        }
    }
    
    
    // MARK: update
    func updateField(title: String, task: CDTask) {
        task.title = title
        saveContext()
    }
    
    func updateField(isCompleted: Bool, task: CDTask) {
        task.isCompleted = isCompleted
        saveContext()
    }
    
    func updateField(isPriority: Bool, task: CDTask) {
        task.isPriority = isPriority
        saveContext()
    }
    
    func updateField(inMyDay: Bool, task: CDTask) {
        task.inMyDay = inMyDay
        saveContext()
    }
    
    func updateField(deadlineDate: Date?, task: CDTask) {
        task.deadlineDate = deadlineDate
        saveContext()
    }
    
    func updateField(reminderDateTime: Date?, task: CDTask) {
        task.reminderDateTime = reminderDateTime
        saveContext()
    }
    
    func updateField(repeatPeriod: String?, task: CDTask) {
        task.repeatPeriod = repeatPeriod
        saveContext()
    }
    
    func updateFields(taskDescription: String?, descriptionUpdatedAt: Date, task: CDTask) {
        task.taskDescription = taskDescription
        task.descriptionUpdatedAt = descriptionUpdatedAt
        
        saveContext()
    }
    
    
    // MARK: insert
    func createWith(title: String, section: TaskSectionCustom?) -> CDTask {
        let task = CDTask(context: getContext())
        task.id = UUID()
        task.title = title
        task.section = section
        
        saveContext()
        
        return task
    }
    
    
    // MARK: delete
    func delete(tasks: [CDTask]) {
        let context = getContext()
        for task in tasks {
            context.delete(task)
        }

        saveContext()
    }
    
}
