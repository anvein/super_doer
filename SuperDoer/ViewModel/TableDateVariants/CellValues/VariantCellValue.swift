
import Foundation
import UIKit

// MARK: cell values objects
class BaseVariantCellValue {
    struct ImageSettings {
        var name: String
        var size: Int = 18
        var weight: UIImage.SymbolWeight = .medium
    }
    
    var imageSettings: ImageSettings
    var title: String
    var isSelected: Bool = false
    
    init(imageSettings: ImageSettings, title: String) {
        self.imageSettings = imageSettings
        self.title = title
    }
}

class DateVariantCellValue: BaseVariantCellValue {
    var date: Date
    var additionalText: String?
    
    init(imageSettings: ImageSettings, title: String, date: Date, additionalText: String? = nil) {
        self.date = date
        
        super.init(imageSettings: imageSettings, title: title)
        
        self.additionalText = additionalText
    }
}

class CustomVariantCellValue: BaseVariantCellValue  {
}
