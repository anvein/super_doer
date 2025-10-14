
import Foundation

/// ViewModel для строки с количеством
class TaskRepeatPeriodAmountRowViewModel: TaskRepeatPeriodRowViewModelType {
    var visibleValue: String
    var value: Int
    var isSelected: Bool = false
    
    init(value: Int) {
        self.value = value
        visibleValue = String(value)
    }
}
