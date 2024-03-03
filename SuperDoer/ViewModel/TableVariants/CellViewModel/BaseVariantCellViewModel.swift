
import Foundation
import UIKit

class BaseVariantCellViewModel {
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
