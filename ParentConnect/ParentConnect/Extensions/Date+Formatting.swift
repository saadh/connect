import Foundation

extension Date {
    var timeString: String {
        let formatter = DateFormatter()
        formatter.timeStyle = .short
        return formatter.string(from: self)
    }

    var dateString: String {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        return formatter.string(from: self)
    }

    var fullDateString: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "EEEE, MMMM d, yyyy"
        return formatter.string(from: self)
    }

    var shortDateString: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "MMM d"
        return formatter.string(from: self)
    }

    var dayOfWeek: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "EEEE"
        return formatter.string(from: self)
    }

    var isToday: Bool {
        return Calendar.current.isDateInToday(self)
    }

    var isTomorrow: Bool {
        return Calendar.current.isDateInTomorrow(self)
    }

    var isWeekend: Bool {
        let weekday = Calendar.current.component(.weekday, from: self)
        return weekday == 1 || weekday == 7 // Sunday or Saturday (Gregorian)
    }

    var isFridayOrSaturday: Bool {
        let weekday = Calendar.current.component(.weekday, from: self)
        return weekday == 6 || weekday == 7 // Friday or Saturday
    }
}
