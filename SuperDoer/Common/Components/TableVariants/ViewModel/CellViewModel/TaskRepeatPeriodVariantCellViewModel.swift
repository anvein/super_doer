import Foundation

final class TaskRepeatPeriodVariantCellViewModel: BaseVariantCellViewModel {
    // TODO: переделать тип на объект периода
    var period: String
    
    init(
        period: String,
        imageSettings: BaseVariantCellViewModel.ImageSettings,
        title: String,
        additionalText: String? = nil,
        isSelected: Bool = false
    ) {
        self.period = period
        super.init(
            imageSettings: imageSettings,
            title: title,
            additionalText: additionalText,
            isSelected: isSelected
        )
    }
}
