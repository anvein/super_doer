extension TaskRepeatPeriodUnit {
    var title: String {
        switch self {
        case .day: "Дн."
        case .week: "Нед."
        case .month: "Мес."
        case .year: "Г."
        }
    }
}
