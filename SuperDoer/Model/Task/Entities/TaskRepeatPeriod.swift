struct TaskRepeatPeriod: Codable, Equatable {
    var unit: TaskRepeatPeriodUnit
    var amount: Int
    var daysOfWeek: Set<DayOfWeek> = .init()
}
