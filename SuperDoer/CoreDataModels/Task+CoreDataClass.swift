
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
