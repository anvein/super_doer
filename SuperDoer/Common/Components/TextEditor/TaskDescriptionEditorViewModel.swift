
import Foundation

class TaskDescriptionEditorViewModel: TextEditorViewModelType {
    
    private var task: CDTask {
        didSet {
            text.value = NSMutableAttributedString()
        }
    }
    
    var title: String? {
        get {
            return task.title
        }
    }
    private var text: UIBox<NSMutableAttributedString?>
    var textObservable: UIBoxObservable<NSMutableAttributedString?> { text.asObservable() }

    init(task: CDTask) {
        self.task = task
        
        if let taskDescription = task.descriptionText {
            text = UIBox(NSMutableAttributedString(string: taskDescription))
        } else {
            text = UIBox(nil)
        }
    }
}
