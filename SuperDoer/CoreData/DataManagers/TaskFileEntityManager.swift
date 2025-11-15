import Foundation

class TaskFileEntityManager {

    private let coreDataStack: CoreDataStack

    // MARK: - Init

    init(coreDataStack: CoreDataStack = .shared) {
        self.coreDataStack = coreDataStack
    }

    // MARK: insert
    func createWith(fileName: String, fileExtension: String, fileSize: Int, task: CDTask) -> TaskFile {
        let file = TaskFile(context: coreDataStack.viewContext)
        file.id = UUID()
        file.fileName = fileName
        file.fileExtension = fileExtension
        file.fileSize = Int32(fileSize)
        file.task = task

        coreDataStack.saveContext()

        return file
    }

    // MARK: delete
    func delete(file: TaskFile) {
        coreDataStack.viewContext.delete(file)
        coreDataStack.saveContext()
    }
}
