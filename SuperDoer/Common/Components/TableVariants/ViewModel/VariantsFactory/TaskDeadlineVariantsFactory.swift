import Foundation

final class TaskDeadlineVariantsFactory: TableVariantsFactory {
    typealias CellValueType = Date

    func buildCellViewModels() -> [VariantCellViewModel<CellValueType>] {
        var cellViewModels = [VariantCellViewModel<CellValueType>]()

        var today = Date()
        today = today.setComponents(hours: 12, minutes: 0, seconds: 0)

        cellViewModels.append(
            .init(
                value: today,
                imageSettings: .init(name: "calendar.badge.clock"),
                title: "Сегодня",
                additionalText: today.formatWith(dateFormat: "EE")
            )
        )

        var tomorrow = Date()
        tomorrow = tomorrow.setComponents(hours: 12, minutes: 0, seconds: 0)
        tomorrow = tomorrow.add(days: 1)

        cellViewModels.append(
            .init(
                value: tomorrow,
                imageSettings: .init(name: "arrow.right.square", size: 20),
                title: "Завтра",
                additionalText: tomorrow.formatWith(dateFormat: "EE")
            )
        )

        cellViewModels.append(
            .init(
                value: tomorrow,
                imageSettings: .init(name: "calendar.day.timeline.right"),
                title: "Следующая неделя (завтра)",
                additionalText: today.formatWith(dateFormat: "EE")
            )
        )

        cellViewModels.append(
            CustomVariantCellViewModel<Date>(
                imageSettings: .init(name: "calendar"),
                title: "Выбрать дату"
            )
        )

        return cellViewModels
    }
}
