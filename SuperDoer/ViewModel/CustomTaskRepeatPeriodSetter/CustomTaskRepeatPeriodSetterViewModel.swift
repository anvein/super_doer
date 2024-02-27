
import Foundation

/// ViewModel для установки кастомного периода повтора задачи
class CustomTaskRepeatPeriodSetterViewModel {
    private var task: Task {
        didSet {
            repeatPeriod = task.repeatPeriod
        }
    }
    
    var isShowReadyButton: Bool = true
    
    // TODO: переделать на другой тип
    var repeatPeriod: String?
    
    init(task: Task) {
        self.task = task
        repeatPeriod = task.repeatPeriod
    }
    
}
