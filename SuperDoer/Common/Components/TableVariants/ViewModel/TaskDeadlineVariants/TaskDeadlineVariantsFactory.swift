import Foundation

final class TaskDeadlineVariantsFactory {
    func buildCellViewModels() -> [BaseVariantCellViewModel] {
        var cellViewModels = [BaseVariantCellViewModel]()

        var today = Date()
        today = today.setComponents(hours: 12, minutes: 0, seconds: 0)

        cellViewModels.append(
            DateVariantCellViewModel(
                date: today,
                imageSettings: DateVariantCellViewModel.ImageSettings(name: "calendar.badge.clock"),
                title: "Сегодня",
                additionalText: today.formatWith(dateFormat: "EE")
            )
        )

        var tomorrow = Date()
        tomorrow = tomorrow.setComponents(hours: 12, minutes: 0, seconds: 0)
        tomorrow = tomorrow.add(days: 1)

        cellViewModels.append(
            DateVariantCellViewModel(
                date: tomorrow,
                imageSettings: DateVariantCellViewModel.ImageSettings(name: "arrow.right.square", size: 20),
                title: "Завтра",
                additionalText: tomorrow.formatWith(dateFormat: "EE")
            )
        )

        cellViewModels.append(
            DateVariantCellViewModel(
                date: tomorrow,
                imageSettings: DateVariantCellViewModel.ImageSettings(name: "calendar.day.timeline.right"),
                title: "Следующая неделя (завтра)",
                additionalText: today.formatWith(dateFormat: "EE")
            )
        )

        cellViewModels.append(
            CustomVariantCellViewModel(
                imageSettings: DateVariantCellViewModel.ImageSettings(name: "calendar"),
                title: "Выбрать дату"
            )
        )

        return cellViewModels
    }
}
