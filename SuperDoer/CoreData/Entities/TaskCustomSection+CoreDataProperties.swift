//
//  TaskSectionCustom+CoreDataProperties.swift
//  SuperDoer
//
//  Created by Виталий Нохрин on 23.02.2024.
//
//

import Foundation
import CoreData


extension CDTaskCustomSection {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<CDTaskCustomSection> {
        return NSFetchRequest<CDTaskCustomSection>(entityName: CDTaskCustomSection.entityName)
    }

    @NSManaged public var deletedAt: Date?
    @NSManaged public var id: UUID?
    @NSManaged public var isArchived: Bool
    @NSManaged public var isCycledList: Bool
    @NSManaged public var order: Int32
    @NSManaged public var tasksCount: Int32
    @NSManaged public var title: String?
    @NSManaged public var titleEmoji: String?
    @NSManaged public var tasks: NSOrderedSet?

}

// MARK: Generated accessors for tasks
extension CDTaskCustomSection {

    @objc(insertObject:inTasksAtIndex:)
    @NSManaged public func insertIntoTasks(_ value: CDTask, at idx: Int)

    @objc(removeObjectFromTasksAtIndex:)
    @NSManaged public func removeFromTasks(at idx: Int)

    @objc(insertTasks:atIndexes:)
    @NSManaged public func insertIntoTasks(_ values: [CDTask], at indexes: NSIndexSet)

    @objc(removeTasksAtIndexes:)
    @NSManaged public func removeFromTasks(at indexes: NSIndexSet)

    @objc(replaceObjectInTasksAtIndex:withObject:)
    @NSManaged public func replaceTasks(at idx: Int, with value: CDTask)

    @objc(replaceTasksAtIndexes:withTasks:)
    @NSManaged public func replaceTasks(at indexes: NSIndexSet, with values: [CDTask])

    @objc(addTasksObject:)
    @NSManaged public func addToTasks(_ value: CDTask)

    @objc(removeTasksObject:)
    @NSManaged public func removeFromTasks(_ value: CDTask)

    @objc(addTasks:)
    @NSManaged public func addToTasks(_ values: NSOrderedSet)

    @objc(removeTasks:)
    @NSManaged public func removeFromTasks(_ values: NSOrderedSet)

}

extension CDTaskCustomSection : Identifiable {

}
