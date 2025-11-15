import Foundation

final class TaskRepeatPeriodVariantsFactory: TableVariantsFactory {
    typealias CellValueType = TaskRepeatPeriod

    // swiftlint:disable function_body_length
    func buildCellViewModels() -> [VariantCellViewModel<CellValueType>] {
        var cellViewModels = [VariantCellViewModel<CellValueType>]()

        cellViewModels.append(
            .init(
                value: .init(unit: .day, amount: 1),
                imageSettings: .init(name: "clock.arrow.circlepath"),
                title: "Каждый день"
            )
        )

        let date = Date()
        cellViewModels.append(
            .init(
                value: .init(
                    unit: .week,
                    amount: 1,
                    daysOfWeek: [Date.now.dayOfWeek ?? .monday]
                ),
                imageSettings: .init(name: "square.grid.3x1.below.line.grid.1x2.fill"),
                title: "Каждую неделю (\(date.formatWith(dateFormat: "EEEEEE").lowercased()))"
            )
        )

        cellViewModels.append(
            .init(
                value: .init(
                    unit: .week,
                    amount: 1,
                    daysOfWeek: [.monday, .tuesday, .wednesday, .thursday, .friday]
                ),
                imageSettings: .init(name: "rectangle.stack.badge.person.crop"),
                title: "Рабочие дни"
            )
        )

        cellViewModels.append(
            .init(
                value: .init(unit: .month, amount: 1),
                imageSettings: .init(name: "square.grid.3x3.topleft.filled"),
                title: "Каждый месяц"
            )
        )

        cellViewModels.append(
            .init(
                value: .init(unit: .year, amount: 1),
                imageSettings: .init(name: "calendar.badge.clock"),
                title: "Каждый год"
            )
        )

        cellViewModels.append(
            CustomVariantCellViewModel<TaskRepeatPeriod>(
                imageSettings: .init(name: "calendar"),
                title: "Настроить период"
            )
        )

        return cellViewModels
    }
    // swiftlint:enable function_body_length
}
