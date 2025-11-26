import Foundation
import UserNotifications

class NotificationService {
    static let shared = NotificationService()

    private init() {}

    func requestAuthorization(completion: @escaping (Bool) -> Void) {
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .badge, .sound]) { granted, error in
            DispatchQueue.main.async {
                if let error = error {
                    print("Notification authorization error: \(error.localizedDescription)")
                    completion(false)
                } else {
                    completion(granted)
                }
            }
        }
    }

    func scheduleAppointmentConfirmation(for appointment: AppointmentRequest) {
        let content = UNMutableNotificationContent()
        content.title = "Appointment Request Submitted"
        content.body = "Your appointment request for \(appointment.studentName ?? "your student") has been submitted successfully."
        content.sound = .default
        content.categoryIdentifier = "APPOINTMENT_SUBMITTED"

        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 1, repeats: false)
        let request = UNNotificationRequest(
            identifier: "appointment_submitted_\(appointment.id)",
            content: content,
            trigger: trigger
        )

        UNUserNotificationCenter.current().add(request) { error in
            if let error = error {
                print("Failed to schedule notification: \(error.localizedDescription)")
            }
        }
    }

    func scheduleStatusUpdateNotification(for appointment: AppointmentRequest, newStatus: AppointmentStatus) {
        let content = UNMutableNotificationContent()

        switch newStatus {
        case .approved:
            content.title = "Appointment Approved"
            content.body = "Your appointment with \(appointment.representativeName ?? "the representative") for \(appointment.studentName ?? "your student") has been approved for \(appointment.formattedDateTime)."
        case .rejected:
            content.title = "Appointment Declined"
            content.body = "Your appointment request for \(appointment.studentName ?? "your student") has been declined. Please try scheduling a different time."
        default:
            return
        }

        content.sound = .default
        content.categoryIdentifier = "APPOINTMENT_STATUS_UPDATE"

        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 1, repeats: false)
        let request = UNNotificationRequest(
            identifier: "appointment_status_\(appointment.id)_\(newStatus.rawValue)",
            content: content,
            trigger: trigger
        )

        UNUserNotificationCenter.current().add(request) { error in
            if let error = error {
                print("Failed to schedule notification: \(error.localizedDescription)")
            }
        }
    }

    func scheduleAppointmentReminder(for appointment: AppointmentRequest) {
        guard appointment.status == .approved else { return }

        let content = UNMutableNotificationContent()
        content.title = "Upcoming Appointment"
        content.body = "Reminder: You have an appointment with \(appointment.representativeName ?? "the representative") tomorrow at \(appointment.formattedTime) for \(appointment.studentName ?? "your student")."
        content.sound = .default
        content.categoryIdentifier = "APPOINTMENT_REMINDER"

        let calendar = Calendar.current
        guard let reminderDate = calendar.date(byAdding: .day, value: -1, to: appointment.date) else { return }

        var dateComponents = calendar.dateComponents([.year, .month, .day], from: reminderDate)
        dateComponents.hour = 18
        dateComponents.minute = 0

        let trigger = UNCalendarNotificationTrigger(dateMatching: dateComponents, repeats: false)
        let request = UNNotificationRequest(
            identifier: "appointment_reminder_\(appointment.id)",
            content: content,
            trigger: trigger
        )

        UNUserNotificationCenter.current().add(request) { error in
            if let error = error {
                print("Failed to schedule reminder: \(error.localizedDescription)")
            }
        }
    }

    func cancelNotifications(for appointmentId: String) {
        let identifiers = [
            "appointment_submitted_\(appointmentId)",
            "appointment_reminder_\(appointmentId)"
        ]
        UNUserNotificationCenter.current().removePendingNotificationRequests(withIdentifiers: identifiers)
    }

    func setupNotificationCategories() {
        let viewAction = UNNotificationAction(
            identifier: "VIEW_ACTION",
            title: "View Details",
            options: .foreground
        )

        let submittedCategory = UNNotificationCategory(
            identifier: "APPOINTMENT_SUBMITTED",
            actions: [viewAction],
            intentIdentifiers: [],
            options: []
        )

        let statusCategory = UNNotificationCategory(
            identifier: "APPOINTMENT_STATUS_UPDATE",
            actions: [viewAction],
            intentIdentifiers: [],
            options: []
        )

        let reminderCategory = UNNotificationCategory(
            identifier: "APPOINTMENT_REMINDER",
            actions: [viewAction],
            intentIdentifiers: [],
            options: []
        )

        UNUserNotificationCenter.current().setNotificationCategories([
            submittedCategory,
            statusCategory,
            reminderCategory
        ])
    }
}
