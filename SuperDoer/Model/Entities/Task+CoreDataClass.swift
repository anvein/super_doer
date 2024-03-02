
import Foundation
import CoreData

@objc(Task)
public class Task: NSManagedObject {
    static let entityName = "Task"
    
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
