import UIKit

class TaskDetailRepeatPeriodCell: TaskDetailLabels2StatesButtonCell {

    override var defaultMainText: String {
        return "Повтор"
    }

    override var showBottomSeparator: Bool {
        return true
    }

    func fillFrom(_ cellValue: TaskDetailRepeatPeriodCellViewModel) {
        switch cellValue.state {
        case .empty:
            value = nil

        case .filled(let periodTitle, let daysOfWeek):
            value = Value(mainText: periodTitle, additionalText: daysOfWeek)
        }
    }

    override func createLeftButtonImage() -> UIImage? {
        let symbolConfig = UIImage.SymbolConfiguration(pointSize: 19, weight: .medium)
        return UIImage(systemName: "repeat")?
            .withConfiguration(symbolConfig)
            .withRenderingMode(.alwaysTemplate)
    }

}
