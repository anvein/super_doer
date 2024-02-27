
import UIKit
import CoreData

class TaskEntityManager: EntityManager {
    // MARK: get
    func getAllTasks() -> [Task] {
        let fetchRequest = NSFetchRequest<Task>(entityName: Task.entityName)
        
        do {
            let tasks = try getContext().fetch(fetchRequest)
            return tasks
        } catch let error as NSError {
            fatalError("getAllTasks error - \(error)")
        }
    }
    
    func getTasks(for taskSection: TaskSectionCustom?) -> [Task] {
        let fetchRequest = Task.fetchRequest()
        
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
    func updateField(title: String, task: Task) {
        task.title = title
        saveContext()
    }
    
    func updateField(isCompleted: Bool, task: Task) {
        task.isCompleted = isCompleted
        saveContext()
    }
    
    func updateField(isPriority: Bool, task: Task) {
        task.isPriority = isPriority
        saveContext()
    }
    
    func updateField(inMyDay: Bool, task: Task) {
        task.inMyDay = inMyDay
        saveContext()
    }
    
    func updateField(deadlineDate: Date?, task: Task) {
        task.deadlineDate = deadlineDate
        saveContext()
    }
    
    func updateField(reminderDateTime: Date?, task: Task) {
        task.reminderDateTime = reminderDateTime
        saveContext()
    }
    
    func updateField(repeatPeriod: String?, task: Task) {
        task.repeatPeriod = repeatPeriod
        saveContext()
    }
    
    func updateFields(taskDescription: String?, descriptionUpdatedAt: Date, task: Task) {
        task.taskDescription = taskDescription
        task.descriptionUpdatedAt = descriptionUpdatedAt
        
        saveContext()
    }
    
    
    // MARK: insert
    func createWith(title: String, section: TaskSectionCustom?) -> Task {
        let task = Task(context: getContext())
        task.id = UUID()
        task.title = title
        task.section = section
        
        saveContext()
        
        return task
    }
    
    
    // MARK: delete
    func delete(tasks: [Task]) {
        let context = getContext()
        for task in tasks {
            context.delete(task)
        }

        saveContext()
    }
    
}
