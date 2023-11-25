
import Foundation
import CoreData

@objc(Task)
public class Task: NSManagedObject {
    static let entityName = "Task"
    
    func getFileBy(id: UUID) -> TaskFile? {
        
        for file in files ?? [] {
            guard let safeFile = file as? TaskFile else {
                continue
            }
            
            if safeFile.id?.uuidString == id.uuidString {
                return safeFile
            }
        }
        
        return nil
    }
}
