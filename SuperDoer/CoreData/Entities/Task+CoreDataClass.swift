import Foundation
import CoreData

@objc(Task)
public class CDTask: NSManagedObject {
    static let entityName = "CDTask"

    // MARK: - Fields Keys

    static let idKey = "id"
    static let isCompletedKey = "isCompleted"
    static let createdAtKey = "createdAt"

    // MARK: -

    func getFileBy(id: UUID) -> TaskFile? {

        for file in files ?? [] {
            guard let file = file as? TaskFile else { continue}

            if file.id?.uuidString == id.uuidString {
                return file
            }
        }

        return nil
    }
}

extension CDTask {
    var titlePrepared: String {
        get { title ?? "No title" }
    }

    var descriptionTextAttributed: NSAttributedString? {
        get {
            guard let data = descriptionTextData else { return nil }
            return try? NSKeyedUnarchiver.unarchivedObject(
                ofClass: NSAttributedString.self,
                from: data
            )
        }
        set {
            guard let newValue = newValue else {
                descriptionTextData = nil
                return
            }
            descriptionTextData = try? NSKeyedArchiver.archivedData(
                withRootObject: newValue,
                requiringSecureCoding: true
            )
        }
    }

    var repeatPeriodStruct: TaskRepeatPeriod? {
        get {
            guard let jsonString = self.repeatPeriod,
                  let data = jsonString.data(using: .utf8) else { return nil }
            return try? JSONDecoder().decode(TaskRepeatPeriod.self, from: data)
        }
        set {
            guard let newValue = newValue,
                  let data = try? JSONEncoder().encode(newValue),
                  let jsonString = String(data: data, encoding: .utf8) else {
                self.repeatPeriod = nil
                return
            }
            self.repeatPeriod = jsonString
        }
    }
}
