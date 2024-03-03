
import Foundation

class TaskRepeatPeriodVariantCellViewModel: BaseVariantCellViewModel {
    // TODO: переделать тип на объект периода
    var period: String?
    
    init(imageSettings: ImageSettings, title: String, period: String?) {
        self.period = period
        
        super.init(imageSettings: imageSettings, title: title)
    }
}
