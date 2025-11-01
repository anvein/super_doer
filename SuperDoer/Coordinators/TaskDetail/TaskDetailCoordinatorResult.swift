import Foundation

enum TaskDetailCoordinatorResult {
    case didEnteredDescriptionEditorContent(NSAttributedString?)
    case didImportedImage(Data?)
    case didImportedFile(URL?)
}
