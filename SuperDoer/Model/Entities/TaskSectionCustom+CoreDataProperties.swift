//
//  TaskList+CoreDataProperties.swift
//  SuperDoer
//
//  Created by Виталий Нохрин on 02.12.2023.
//
//

import Foundation
import CoreData


extension TaskSectionCustom {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<TaskSectionCustom> {
        return NSFetchRequest<TaskSectionCustom>(entityName: TaskSectionCustom.entityName)
    }

    @NSManaged public var tasksCount: Int32
    @NSManaged public var deletedAt: Date?
    @NSManaged public var id: UUID?
    @NSManaged public var isCycledList: Bool
    @NSManaged public var order: Int32
    @NSManaged public var title: String?
    @NSManaged public var titleEmoji: String?
    @NSManaged public var tasks: NSOrderedSet?

}

// MARK: Generated accessors for tasks
extension TaskSectionCustom {

    @objc(insertObject:inTasksAtIndex:)
    @NSManaged public func insertIntoTasks(_ value: Task, at idx: Int)

    @objc(removeObjectFromTasksAtIndex:)
    @NSManaged public func removeFromTasks(at idx: Int)

    @objc(insertTasks:atIndexes:)
    @NSManaged public func insertIntoTasks(_ values: [Task], at indexes: NSIndexSet)

    @objc(removeTasksAtIndexes:)
    @NSManaged public func removeFromTasks(at indexes: NSIndexSet)

    @objc(replaceObjectInTasksAtIndex:withObject:)
    @NSManaged public func replaceTasks(at idx: Int, with value: Task)

    @objc(replaceTasksAtIndexes:withTasks:)
    @NSManaged public func replaceTasks(at indexes: NSIndexSet, with values: [Task])

    @objc(addTasksObject:)
    @NSManaged public func addToTasks(_ value: Task)

    @objc(removeTasksObject:)
    @NSManaged public func removeFromTasks(_ value: Task)

    @objc(addTasks:)
    @NSManaged public func addToTasks(_ values: NSOrderedSet)

    @objc(removeTasks:)
    @NSManaged public func removeFromTasks(_ values: NSOrderedSet)

}

extension TaskSectionCustom : Identifiable {

}
