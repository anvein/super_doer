import Foundation
import UIKit

class VariantCellViewModel<Value>: VariantCellViewModelProtocol {
    var value: Value?
    var imageSettings: VariantCellVMImageSettings
    var title: String
    var additionalText: String? = nil
    var isSelected: Bool = false

    init(
        value: Value?,
        imageSettings: VariantCellVMImageSettings,
        title: String,
        additionalText: String? = nil,
        isSelected: Bool = false
    ) {
        self.value = value
        self.imageSettings = imageSettings
        self.title = title
        self.additionalText = additionalText
        self.isSelected = isSelected
    }
}
