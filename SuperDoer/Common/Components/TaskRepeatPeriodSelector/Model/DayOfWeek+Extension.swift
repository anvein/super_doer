extension DayOfWeek {
    var shortTitle: String {
        switch self {
        case .monday: return "пн"
        case .tuesday: return "вт"
        case .wednesday: return "ср"
        case .thursday: return "чт"
        case .friday: return "пт"
        case .saturday: return "сб"
        case .sunday: return "вс"
        }
    }
}
