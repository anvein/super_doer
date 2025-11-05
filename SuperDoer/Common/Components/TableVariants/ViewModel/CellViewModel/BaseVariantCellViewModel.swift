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
    var additionalText: String? = nil
    var isSelected: Bool = false

    init(
        imageSettings: ImageSettings,
        title: String,
        additionalText: String? = nil,
        isSelected: Bool = false
    ) {
        self.imageSettings = imageSettings
        self.title = title
        self.additionalText = additionalText
        self.isSelected = isSelected
    }
}
