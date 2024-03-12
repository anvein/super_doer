
import Foundation

class TaskFileEntityManager: EntityManager {
    
    // MARK: insert
    func createWith(fileName: String, fileExtension: String, fileSize: Int, task: CDTask) -> TaskFile {
        let file = TaskFile(context: getContext())
        file.id = UUID()
        file.fileName = fileName
        file.fileExtension = fileExtension
        file.fileSize = Int32(fileSize)
        file.task = task
        
        saveContext()
        
        return file
    }
    
    // MARK: delete
    func delete(file: TaskFile) {
        getContext().delete(file)
        saveContext()
    }
}
