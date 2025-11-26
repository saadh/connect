import Foundation

struct ValidationResult {
    let isValid: Bool
    let errorMessage: String?

    static let valid = ValidationResult(isValid: true, errorMessage: nil)

    static func invalid(_ message: String) -> ValidationResult {
        return ValidationResult(isValid: false, errorMessage: message)
    }
}

class AppointmentValidationService {
    static let shared = AppointmentValidationService()

    private let calendar = Calendar.current
    private let dataService = MockDataService.shared

    private init() {}

    // MARK: - Time Constants
    private let morningStartHour = 7
    private let morningStartMinute = 30
    private let lunchStartHour = 11
    private let lunchEndHour = 13
    private let eveningEndHour = 13

    // MARK: - Date Validation
    func isDateAvailable(_ date: Date) -> ValidationResult {
        let today = calendar.startOfDay(for: Date())
        let selectedDay = calendar.startOfDay(for: date)

        // Check if date is in the past or today
        if selectedDay <= today {
            return .invalid("Same-day bookings are not allowed. Please select a future date.")
        }

        // Check maximum date range (30 days)
        guard let maxDate = calendar.date(byAdding: .day, value: 30, to: today) else {
            return .invalid("Unable to calculate date range.")
        }

        if selectedDay > maxDate {
            return .invalid("Appointments can only be scheduled up to 30 days in advance.")
        }

        // Check for blocked days (Friday = 6, Saturday = 7 in Gregorian)
        let weekday = calendar.component(.weekday, from: date)
        if weekday == 6 { // Friday
            return .invalid("Appointments are not available on Fridays.")
        }
        if weekday == 7 { // Saturday
            return .invalid("Appointments are not available on Saturdays.")
        }

        return .valid
    }

    func getMinimumDate() -> Date {
        let tomorrow = calendar.date(byAdding: .day, value: 1, to: Date()) ?? Date()
        return calendar.startOfDay(for: tomorrow)
    }

    func getMaximumDate() -> Date {
        let maxDate = calendar.date(byAdding: .day, value: 30, to: Date()) ?? Date()
        return calendar.startOfDay(for: maxDate)
    }

    func isWeekendOrBlocked(_ date: Date) -> Bool {
        let weekday = calendar.component(.weekday, from: date)
        return weekday == 6 || weekday == 7 // Friday or Saturday
    }

    // MARK: - Time Validation
    func isTimeAvailable(_ time: Date) -> ValidationResult {
        let hour = calendar.component(.hour, from: time)
        let minute = calendar.component(.minute, from: time)
        let timeInMinutes = hour * 60 + minute

        let morningStart = morningStartHour * 60 + morningStartMinute // 7:30 AM = 450
        let lunchStart = lunchStartHour * 60 // 11:00 AM = 660
        let lunchEnd = lunchEndHour * 60 // 1:00 PM = 780
        let eveningEnd = eveningEndHour * 60 // 1:00 PM = 780

        // Available time: 7:30 AM - 11:00 AM only
        if timeInMinutes < morningStart {
            return .invalid("Appointments are available from 7:30 AM. Please select a later time.")
        }

        if timeInMinutes >= lunchStart {
            return .invalid("Appointments are only available until 11:00 AM. Please select an earlier time.")
        }

        return .valid
    }

    func getAvailableTimeSlots() -> [Date] {
        var slots: [Date] = []
        let baseDate = Date()

        // Generate time slots from 7:30 AM to 10:30 AM (allowing 30-min appointments to end by 11 AM)
        var components = calendar.dateComponents([.year, .month, .day], from: baseDate)
        components.hour = morningStartHour
        components.minute = morningStartMinute

        guard var currentSlot = calendar.date(from: components) else { return slots }

        let endHour = lunchStartHour
        let endMinute = 0
        components.hour = endHour
        components.minute = endMinute
        guard let endTime = calendar.date(from: components) else { return slots }

        while currentSlot < endTime {
            slots.append(currentSlot)
            guard let nextSlot = calendar.date(byAdding: .minute, value: 30, to: currentSlot) else { break }
            currentSlot = nextSlot
        }

        return slots
    }

    // MARK: - Student Validation
    func canCreateAppointment(for studentId: String) -> ValidationResult {
        // Check for active appointment
        if dataService.hasActiveAppointment(for: studentId) {
            guard let student = dataService.getStudent(by: studentId) else {
                return .invalid("This student already has an active appointment request.")
            }
            return .invalid("\(student.name) already has an active appointment request. Please wait until the current request is resolved.")
        }

        // Check weekly limit
        if dataService.hasAppointmentThisWeek(for: studentId) {
            guard let student = dataService.getStudent(by: studentId) else {
                return .invalid("You've already scheduled an appointment for this student this week.")
            }
            return .invalid("You've already scheduled an appointment for \(student.name) this week. Only one appointment per student is allowed per calendar week.")
        }

        return .valid
    }

    // MARK: - Purpose Validation
    func validatePurpose(_ purpose: String) -> ValidationResult {
        let trimmedPurpose = purpose.trimmingCharacters(in: .whitespacesAndNewlines)

        if trimmedPurpose.isEmpty {
            return .invalid("Please describe the purpose of your meeting.")
        }

        // Count sentence-ending punctuation
        let sentenceEndings = trimmedPurpose.filter { ".!?" .contains($0) }
        if sentenceEndings.count < 2 {
            return .invalid("Please provide at least 2 complete sentences describing the purpose of your meeting.")
        }

        if trimmedPurpose.count < 20 {
            return .invalid("Please provide more detail about the purpose of your meeting (minimum 20 characters).")
        }

        return .valid
    }

    func countSentences(in text: String) -> Int {
        let trimmedText = text.trimmingCharacters(in: .whitespacesAndNewlines)
        let sentenceEndings = trimmedText.filter { ".!?".contains($0) }
        return sentenceEndings.count
    }

    // MARK: - Complete Appointment Validation
    func validateAppointment(
        studentId: String,
        representativeId: String?,
        date: Date?,
        time: Date?,
        duration: AppointmentDuration?,
        category: AppointmentCategory?,
        purpose: String
    ) -> ValidationResult {
        // Validate student eligibility
        let studentValidation = canCreateAppointment(for: studentId)
        if !studentValidation.isValid {
            return studentValidation
        }

        // Validate representative selection
        guard representativeId != nil else {
            return .invalid("Please select a school representative.")
        }

        // Validate date
        guard let date = date else {
            return .invalid("Please select a date for your appointment.")
        }
        let dateValidation = isDateAvailable(date)
        if !dateValidation.isValid {
            return dateValidation
        }

        // Validate time
        guard let time = time else {
            return .invalid("Please select a time for your appointment.")
        }
        let timeValidation = isTimeAvailable(time)
        if !timeValidation.isValid {
            return timeValidation
        }

        // Validate duration
        guard duration != nil else {
            return .invalid("Please select a duration for your appointment.")
        }

        // Validate category
        guard category != nil else {
            return .invalid("Please select a category for your appointment.")
        }

        // Validate purpose
        let purposeValidation = validatePurpose(purpose)
        if !purposeValidation.isValid {
            return purposeValidation
        }

        return .valid
    }
}
