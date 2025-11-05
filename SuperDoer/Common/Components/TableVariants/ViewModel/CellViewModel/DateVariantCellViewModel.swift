import Foundation

final class DateVariantCellViewModel: BaseVariantCellViewModel {
    var date: Date

    init(
        date: Date,
        imageSettings: BaseVariantCellViewModel.ImageSettings,
        title: String,
        additionalText: String? = nil,
        isSelected: Bool = false
    ) {
        self.date = date
        super.init(
            imageSettings: imageSettings,
            title: title,
            additionalText: additionalText,
            isSelected: isSelected
        )
    }
}
