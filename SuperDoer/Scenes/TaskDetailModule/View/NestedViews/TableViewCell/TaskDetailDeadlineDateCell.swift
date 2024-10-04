
import UIKit

/// Кнопка-ячейка "Срок выполнения задачи"
class TaskDetailDeadlineDateCell: TaskDetailLabels2StatesButtonCell {
    
    override var defaultMainText: String {
        return "Добавить дату выполнения"
    }
    
    func fillFrom(_ cellValue: DeadlineDateCellViewModel) {
        if let deadlineDate = cellValue.date {
            // TODO: Сделать формирование красивой даты (сегодня, завтра + не выводить текущий год)
            let stringDate = deadlineDate.formatWith(dateFormat: "EEEEEE, d MMMM y")
            value = Value(mainText: "Срок: \(stringDate)")
        } else {
            value = nil
        }
    }
    
    override func createLeftButtonImage() -> UIImage? {
        let symbolConfig = UIImage.SymbolConfiguration(pointSize: 19, weight: .semibold)
        
        return UIImage(systemName: "calendar.badge.clock")?
            .withConfiguration(symbolConfig)
            .withRenderingMode(.alwaysTemplate)
    }
    
}
