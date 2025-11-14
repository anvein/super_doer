
import Foundation

extension Date {
    /// Проверяет, что год, месяц и день у дат совпадает
    func isEqualDate(date2: Date) -> Bool {
        let selfDateComponents = Calendar.current.dateComponents([.year, .month, .day], from: self)
        let date2Components = Calendar.current.dateComponents([.year, .month, .day], from: date2)

        guard let selfDay = selfDateComponents.day, let selfMonth = selfDateComponents.month, let selfYear = selfDateComponents.year, let date2Day = date2Components.day, let date2Month = date2Components.month, let date2Year = date2Components.year else {
            return false
        }

        return selfDay == date2Day && selfMonth == date2Month && selfYear == date2Year
    }

    func setComponents(hours: Int, minutes: Int, seconds: Int) -> Date {
        var components = Calendar.current.dateComponents([.year, .month, .day, .hour, .minute], from: self)
        components.hour = hours
        components.minute = minutes
        components.second = seconds

        let date = Calendar.current.date(from: components)
        guard let safeDate = date else {
            fatalError("Ошибка создания даты") //  TODO: переработать ошибку
        }

        return safeDate
    }

    func add(years: Int = 0, months: Int = 0, days: Int = 0, hours: Int = 0, minutes: Int = 0, seconds: Int = 0) -> Date {
        var components  = Calendar.current.dateComponents([.year, .month, .day, .hour, .minute, .second], from: self)
        components.year = (components.year ?? 0) + years
        components.month = (components.month ?? 0) + months
        components.day = (components.day ?? 0) + days
        components.hour = (components.hour ?? 0) + hours
        components.minute = (components.minute ?? 0) + minutes
        components.second = (components.second ?? 0) + seconds

        let newDate = Calendar.current.date(from: components)
        guard let safeNewDate = newDate else {
            fatalError("Ошибка создания даты") //  TODO: переработать ошибку
        }

        return safeNewDate
    }

    func formatWith(dateFormat: String, locale: String = "ru_RU") -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.locale = Locale(identifier: locale)
        dateFormatter.dateFormat = dateFormat

        return dateFormatter.string(from: self)
    }

    var dayOfWeek: DayOfWeek? {
        let weekday = Calendar.current.component(.weekday, from: self)
        return .buildFrom(weekdayIndex: weekday)
    }
}
