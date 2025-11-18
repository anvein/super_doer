import Foundation

class TaskFileEntityManager {

    private let coreDataStack: CoreDataStack

    // MARK: - Init

    init(coreDataStack: CoreDataStack = .shared) {
        self.coreDataStack = coreDataStack
    }

    // MARK: insert
    func createWith(fileName: String, fileExtension: String, fileSize: Int, task: CDTask) -> CDTaskFile {
        let file = CDTaskFile(context: coreDataStack.viewContext)
        file.id = UUID()
        file.fileName = fileName
        file.fileExtension = fileExtension
        file.fileSize = Int32(fileSize)
        file.task = task

        coreDataStack.saveContext()

        return file
    }

    // MARK: delete
    func delete(file: CDTaskFile) {
        coreDataStack.viewContext.delete(file)
        coreDataStack.saveContext()
    }
}
