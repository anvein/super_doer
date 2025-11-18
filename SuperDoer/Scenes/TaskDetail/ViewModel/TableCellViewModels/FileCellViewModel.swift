import Foundation

struct FileCellViewModel: TaskDetailTableCellViewModelType {
    struct Data {
        var id: UUID
        var name: String
        var fileExtension: String
        var size: Int

        var titleForDelete: String {
            self.name
        }
    }

    enum State {
        case incompleteData
        case data(Data)
    }

    var state: State

    init(file: CDTaskFile) {
        let state: FileCellViewModel.State
        if let id = file.id,
            let name = file.fileName,
            let fileExt = file.fileExtension {
            state = .data(
                .init(id: id, name: name, fileExtension: fileExt, size: Int(file.fileSize))
            )
        } else {
            state = .incompleteData
        }

        self.state = state
    }
}
