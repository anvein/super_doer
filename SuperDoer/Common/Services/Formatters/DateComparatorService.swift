import Foundation

final class DateComparatorService {
    func isDateInCurrentYear(_ date: Date) -> Bool {
        let calendar = Calendar.current
        let currentYear = calendar.component(.year, from: Date())
        let dateYear = calendar.component(.year, from: date)

        return currentYear == dateYear
    }

    func isDateOfYesterdayOrPreviously(_ date: Date) -> Bool {
        let calendar = Calendar.current
        let currentDate = Date()
        guard let yesterDay = calendar.date(byAdding: .day, value: -1, to: currentDate) else { return false }

        return calendar.isDateInYesterday(date) || date <= yesterDay
    }

}
