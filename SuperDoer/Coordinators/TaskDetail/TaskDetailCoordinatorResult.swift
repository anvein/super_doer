import Foundation

enum TaskDetailCoordinatorResult {
    case didEnteredDescriptionEditorContent(NSAttributedString?)
    case didImportedImage(Data?)
    case didImportedFile(URL?)
    case didDeleteTaskFileConfirmed(TaskFileDeletableViewModel)
    case didDeleteTaskFileCanceled
}
