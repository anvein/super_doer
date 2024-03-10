
import Foundation
import CoreData

@objc(Task)
public class CDTask: NSManagedObject {
    static let entityName = "CDTask"
    
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
