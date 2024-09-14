
import Foundation

/// ViewModel для строки с типом периода
class TaskRepeatPeriodTypeRowViewModel: TaskRepeatPeriodRowViewModelType {
    // TODO: вынести в модель
    enum TypeName: String, CaseIterable {
        case day
        case week
        case month
        case year
        
        
        var visibleValue: String {
            switch self {
            case .day:
                return "Дн."
            case .week:
                return "Нед."
            case .month:
                return "Мес."
            case .year:
                return "Г."
            }
        }
    }
    
    var visibleValue: String
    var value: TypeName
    var isSelected: Bool = false
    
    init(value: TypeName) {
        self.value = value
        visibleValue = String(value.visibleValue)
    }
}
