
import Foundation

class DateVariantCellViewModel: BaseVariantCellViewModel {
    var date: Date
    var additionalText: String?
    
    init(imageSettings: ImageSettings, title: String, date: Date, additionalText: String? = nil) {
        self.date = date
        
        super.init(imageSettings: imageSettings, title: title)
        
        self.additionalText = additionalText
    }
}
