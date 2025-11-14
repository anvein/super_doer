struct TaskDetailRepeatPeriodCellViewModel: TaskDetailTableCellViewModelType {
    enum State {
        case empty
        case filled(periodTitle: String, daysOfWeek: String?)
    }

    var state: State

    static func buildFrom(_ repeatPeriod: TaskRepeatPeriod?) -> Self {
        if let repeatPeriod {
            let sortedDaysOfWeek = DayOfWeek.allCases.filter { repeatPeriod.daysOfWeek.contains($0) }
            return .init(
                state: .filled(
                    periodTitle: repeatPeriod.detailTitle,
                    daysOfWeek: sortedDaysOfWeek
                        .map { $0.shortTitle.lowercased() }
                        .joined(separator: ", ")
                )
            )
        } else {
            return .init(state: .empty)
        }
    }
}
