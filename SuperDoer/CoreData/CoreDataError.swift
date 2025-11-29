import Foundation
import CoreData

enum CoreDataError: Error {
    enum CoreDataOperation {
        case insert
        case delete
        case udpate
        case fetch
    }

    case operationFailed(CoreDataOperation, entityName: String, error: Error)
    case saveFailed(error: Error)
    case invalidData(reason: String)
    case common(error: Error)
}
