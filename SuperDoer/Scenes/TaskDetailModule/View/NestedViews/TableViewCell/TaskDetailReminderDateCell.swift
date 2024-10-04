
import UIKit

/// Кнопка-ячейка "Установить напоминание для задачи"
class TaskDetailReminderDateCell: TaskDetailLabels2StatesButtonCell {

    override var defaultMainText: String {
        return "Напомнить"
    }
    
    /// Управлять контентом и состоянием кнопки надо через этот метод
    func fillFrom(_ cellValue: ReminderDateCellViewModel) {
        if let date = cellValue.dateTime {
            let dateFormatter = DateFormatter()
            dateFormatter.locale = Locale(identifier: "ru_RU")
            
            dateFormatter.dateFormat = "HH:mm"
            let timeString = dateFormatter.string(from: date)
            
            // TODO: Сделать формирование красивой даты (сегодня, завтра)
            // + не выводить год, если это текущий год
            dateFormatter.dateFormat = "EEEEEE, d MMMM"
            
            value = Value(
                mainText: "Напомнить мне в \(timeString)",
                additionalText: dateFormatter.string(from: date)
            )
        } else {
            value = nil
        }
    }
    
    override func createLeftButtonImage() -> UIImage? {
        let symbolConfig = UIImage.SymbolConfiguration(
            pointSize: 19,
            weight: .semibold
        )
        
        return UIImage(systemName: "bell")?
            .withConfiguration(symbolConfig)
            .withRenderingMode(.alwaysTemplate)
    }
    
}
