
import UIKit

/// Кнопка-ячейка "Период повтора задачи"
class RepeatPeriodButtonCell: TaskDetailLabels2StatesButtonCell {

    class override var identifier: String {
        return "RepeatPeriodButtonCell"
    }
    
    override var defaultMainText: String {
        return "Повтор"
    }
    
    override var showBottomSeparator: Bool {
        return true
    }
    
    func fillFrom(_ cellValue: RepeatPeriodCellValue) {
        if let repeatePeriod = cellValue.period {
            let arrMiniText = ["вт, чт", nil]
            let forMiniText = arrMiniText.randomElement()!
            
            value = Value(mainText: cellValue.period, additionalText: forMiniText)
        } else {
            value = nil
        }
    }
    
    override func createLeftButtonImage() -> UIImage? {
        let symbolConfig = UIImage.SymbolConfiguration(pointSize: 19, weight: .medium)
        
        return UIImage(systemName: "repeat")?
            .withConfiguration(symbolConfig)
            .withRenderingMode(.alwaysTemplate)
    }
    
}
