import Foundation
import SwiftUI
import Combine

@MainActor
class AppointmentViewModel: ObservableObject {
    // MARK: - Services
    private let dataService = MockDataService.shared
    private let validationService = AppointmentValidationService.shared
    private let notificationService = NotificationService.shared

    // MARK: - Published Properties
    @Published var students: [Student] = []
    @Published var studentsBySchool: [String: [Student]] = [:]
    @Published var selectedStudent: Student?
    @Published var representatives: [SchoolRepresentative] = []
    @Published var selectedRepresentative: SchoolRepresentative?
    @Published var selectedDate: Date = Date()
    @Published var selectedTime: Date = Date()
    @Published var selectedDuration: AppointmentDuration = .fifteenMinutes
    @Published var selectedCategory: AppointmentCategory?
    @Published var purpose: String = ""
    @Published var availableTimeSlots: [Date] = []

    @Published var isLoading: Bool = false
    @Published var showError: Bool = false
    @Published var errorMessage: String = ""
    @Published var showSuccess: Bool = false
    @Published var successMessage: String = ""

    @Published var appointments: [AppointmentRequest] = []
    @Published var createdAppointment: AppointmentRequest?

    @Published var canProceedToRepresentative: Bool = false
    @Published var canProceedToDateTime: Bool = false
    @Published var canProceedToCategory: Bool = false
    @Published var canProceedToPurpose: Bool = false
    @Published var canSubmit: Bool = false

    @Published var purposeValidationMessage: String = ""
    @Published var sentenceCount: Int = 0

    // MARK: - Initialization
    init() {
        loadInitialData()
        setupValidation()
    }

    private func loadInitialData() {
        dataService.setupInitialAppointments()
        students = dataService.students
        studentsBySchool = dataService.getStudentsBySchool()
        appointments = dataService.getAllAppointments()
        availableTimeSlots = validationService.getAvailableTimeSlots()

        // Set default time to first available slot
        if let firstSlot = availableTimeSlots.first {
            selectedTime = firstSlot
        }

        // Set minimum date to tomorrow
        selectedDate = validationService.getMinimumDate()
    }

    private func setupValidation() {
        // Validation will be triggered manually when needed
    }

    // MARK: - Student Selection
    func selectStudent(_ student: Student) {
        selectedStudent = student
        loadRepresentatives(for: student.schoolId)
        validateStudentSelection()
    }

    func validateStudentSelection() {
        guard let student = selectedStudent else {
            canProceedToRepresentative = false
            return
        }

        let validation = validationService.canCreateAppointment(for: student.id)
        if validation.isValid {
            canProceedToRepresentative = true
            errorMessage = ""
        } else {
            canProceedToRepresentative = false
            errorMessage = validation.errorMessage ?? "Cannot create appointment for this student."
        }
    }

    func hasActiveAppointment(for studentId: String) -> Bool {
        return dataService.hasActiveAppointment(for: studentId)
    }

    func getActiveAppointment(for studentId: String) -> AppointmentRequest? {
        return dataService.getActiveAppointment(for: studentId)
    }

    // MARK: - Representative Selection
    private func loadRepresentatives(for schoolId: String) {
        representatives = dataService.getRepresentatives(for: schoolId)
    }

    func selectRepresentative(_ representative: SchoolRepresentative) {
        selectedRepresentative = representative
        validateRepresentativeSelection()
    }

    func validateRepresentativeSelection() {
        canProceedToDateTime = selectedRepresentative != nil
    }

    func getRepresentativesByTitle() -> [RepresentativeTitle: [SchoolRepresentative]] {
        var grouped: [RepresentativeTitle: [SchoolRepresentative]] = [:]
        for rep in representatives {
            if grouped[rep.title] == nil {
                grouped[rep.title] = []
            }
            grouped[rep.title]?.append(rep)
        }
        return grouped
    }

    // MARK: - Date/Time Selection
    func validateDateTime() {
        let dateValidation = validationService.isDateAvailable(selectedDate)
        let timeValidation = validationService.isTimeAvailable(selectedTime)

        if dateValidation.isValid && timeValidation.isValid {
            canProceedToCategory = true
            errorMessage = ""
        } else {
            canProceedToCategory = false
            errorMessage = dateValidation.errorMessage ?? timeValidation.errorMessage ?? "Invalid date/time selection."
        }
    }

    func isDateSelectable(_ date: Date) -> Bool {
        return validationService.isDateAvailable(date).isValid
    }

    func isWeekendOrBlocked(_ date: Date) -> Bool {
        return validationService.isWeekendOrBlocked(date)
    }

    func getMinimumDate() -> Date {
        return validationService.getMinimumDate()
    }

    func getMaximumDate() -> Date {
        return validationService.getMaximumDate()
    }

    // MARK: - Category Selection
    func selectCategory(_ category: AppointmentCategory) {
        selectedCategory = category
        validateCategorySelection()
    }

    func validateCategorySelection() {
        canProceedToPurpose = selectedCategory != nil
    }

    // MARK: - Purpose Validation
    func validatePurpose() {
        let validation = validationService.validatePurpose(purpose)
        sentenceCount = validationService.countSentences(in: purpose)

        if validation.isValid {
            canSubmit = true
            purposeValidationMessage = "Purpose description is complete."
        } else {
            canSubmit = false
            purposeValidationMessage = validation.errorMessage ?? "Please complete the purpose description."
        }
    }

    // MARK: - Submit Appointment
    func submitAppointment() async {
        guard let student = selectedStudent,
              let representative = selectedRepresentative,
              let category = selectedCategory else {
            showError(message: "Please complete all required fields.")
            return
        }

        // Final validation
        let validation = validationService.validateAppointment(
            studentId: student.id,
            representativeId: representative.id,
            date: selectedDate,
            time: selectedTime,
            duration: selectedDuration,
            category: category,
            purpose: purpose
        )

        guard validation.isValid else {
            showError(message: validation.errorMessage ?? "Validation failed.")
            return
        }

        isLoading = true

        // Simulate network delay
        try? await Task.sleep(nanoseconds: 1_500_000_000) // 1.5 seconds

        let appointment = AppointmentRequest(
            studentId: student.id,
            representativeId: representative.id,
            date: selectedDate,
            time: selectedTime,
            duration: selectedDuration,
            category: category,
            purpose: purpose,
            status: .pending,
            studentName: student.name,
            representativeName: representative.name,
            representativeTitle: representative.title,
            schoolName: student.schoolName
        )

        dataService.addAppointment(appointment)
        notificationService.scheduleAppointmentConfirmation(for: appointment)

        createdAppointment = appointment
        appointments = dataService.getAllAppointments()

        isLoading = false
        showSuccess(message: "Your appointment request has been submitted successfully!")

        // Trigger haptic feedback
        let generator = UINotificationFeedbackGenerator()
        generator.notificationOccurred(.success)
    }

    // MARK: - Reset Flow
    func resetFlow() {
        selectedStudent = nil
        selectedRepresentative = nil
        selectedDate = validationService.getMinimumDate()
        if let firstSlot = availableTimeSlots.first {
            selectedTime = firstSlot
        }
        selectedDuration = .fifteenMinutes
        selectedCategory = nil
        purpose = ""
        createdAppointment = nil

        canProceedToRepresentative = false
        canProceedToDateTime = false
        canProceedToCategory = false
        canProceedToPurpose = false
        canSubmit = false

        errorMessage = ""
        purposeValidationMessage = ""
        sentenceCount = 0
    }

    // MARK: - Error/Success Handling
    private func showError(message: String) {
        errorMessage = message
        showError = true

        let generator = UINotificationFeedbackGenerator()
        generator.notificationOccurred(.error)
    }

    private func showSuccess(message: String) {
        successMessage = message
        showSuccess = true
    }

    // MARK: - Appointments List
    func refreshAppointments() {
        appointments = dataService.getAllAppointments()
    }

    func getAppointments(for studentId: String) -> [AppointmentRequest] {
        return dataService.getAppointments(for: studentId)
    }
}
