final class CustomVariantCellViewModel<Value>: VariantCellViewModel<Value>, CustomVariantCellViewModelProtocol {

    init(
        imageSettings: VariantCellVMImageSettings,
        title: String,
        additionalText: String? = nil,
        isSelected: Bool = false
    ) {
        super.init(
            value: nil,
            imageSettings: imageSettings,
            title: title,
            additionalText: additionalText,
            isSelected: isSelected
        )
    }
}

protocol CustomVariantCellViewModelProtocol { }
