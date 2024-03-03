
import Foundation

class TaskDescriptionEditorViewModel: TextEditorViewModelType {
    
    private var task: Task {
        didSet {
            text.value = NSMutableAttributedString()
        }
    }
    
    var title: String? {
        get {
            return task.title
        }
    }
    var text: Box<NSMutableAttributedString?>
    
    init(task: Task) {
        self.task = task
        
        if let taskDescription = task.taskDescription {
            text = Box(NSMutableAttributedString(string: taskDescription))
        } else {
            text = Box(nil)
        }
    }
}
