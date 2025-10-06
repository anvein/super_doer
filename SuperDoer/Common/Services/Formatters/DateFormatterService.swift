
import Foundation

final class DateFormatterService {

    private(set) var locale: Locale

    private let dateComparator: DateComparatorService

    init(
        locale: Locale = Locale(identifier: "ru_RU"),
        dateComparator: DateComparatorService = .init()
    ) {
        self.locale = locale
        self.dateComparator = dateComparator
    }

    // MARK: - Methods

    func formatDealineAtInTaskList(date: Date) -> String {
        let calendar = Calendar.current

        if calendar.isDateInToday(date) {
            return "сегодня"
        } else if calendar.isDateInTomorrow(date) {
            return "завтра"
        } else if calendar.isDateInYesterday(date) {
            return "вчера"
        }

        let dateFormatter = DateFormatter()
        dateFormatter.locale = self.locale

        if dateComparator.isDateInCurrentYear(date) {
            dateFormatter.dateFormat = "EEEEEE, d MMM"
        } else {
            dateFormatter.dateFormat = "EEEEEE, d MMM YYYY г."
        }

        return dateFormatter.string(from: date)
    }

    // не используется, можно удалить (выдает: через 23 часа и т.д.)
    func formatRelativeDate(_ date: Date) -> String {
        let formatter = RelativeDateTimeFormatter()
        formatter.locale = self.locale

        formatter.dateTimeStyle = .named
        formatter.unitsStyle = .short

        return formatter.string(for: date) ?? ""
    }
}
