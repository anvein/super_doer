import Foundation

struct FileCellViewModel: TaskDetailTableCellViewModelType {
    var id: UUID
    var name: String
    var fileExtension: String
    var size: Int

    var titleForDelete: String {
        return name
    }
}
