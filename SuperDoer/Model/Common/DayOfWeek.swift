enum DayOfWeek: String, CaseIterable, Codable {
    case monday
    case tuesday
    case wednesday
    case thursday
    case friday
    case saturday
    case sunday

    static func buildFrom(weekdayIndex: Int) -> Self? {
        switch weekdayIndex {
        case 2: .monday
        case 3: .tuesday
        case 4: .wednesday
        case 5: .thursday
        case 6: .friday
        case 7: .saturday
        case 1: .sunday
        default: nil
        }
    }
}
