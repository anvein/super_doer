import Foundation

struct TaskFileEntity {
    var id: UUID?
    var fileExtension: String?
    var fileName: String?
    var fileSize: Int
    var taskId: UUID?

    init(cdTaskFile: CDTaskFile) {
        self.id = cdTaskFile.id
        self.fileExtension = cdTaskFile.fileExtension
        self.fileName = cdTaskFile.fileName
        self.fileSize = Int(cdTaskFile.fileSize)
        self.taskId = cdTaskFile.task?.id
    }
}
