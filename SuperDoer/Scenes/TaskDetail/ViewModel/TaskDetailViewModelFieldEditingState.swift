import Foundation

enum TaskDetailViewModelFieldEditingState: Equatable {
    case taskTitleEditing
    case subtaskAdding
    case subtastEditing(indexPath: IndexPath)
}
