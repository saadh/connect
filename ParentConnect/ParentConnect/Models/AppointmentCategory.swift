import Foundation

enum AppointmentCategory: String, Codable, CaseIterable, Identifiable {
    case academicPerformance = "academic_performance"
    case studentBehavior = "student_behavior"
    case absences = "absences"
    case advisory = "advisory"
    case grievance = "grievance"
    case other = "other"

    var id: String { rawValue }

    var displayName: String {
        switch self {
        case .academicPerformance:
            return "Academic Performance"
        case .studentBehavior:
            return "Student Behavior"
        case .absences:
            return "Absences"
        case .advisory:
            return "Advisory"
        case .grievance:
            return "Grievance"
        case .other:
            return "Other"
        }
    }

    var icon: String {
        switch self {
        case .academicPerformance:
            return "graduationcap.fill"
        case .studentBehavior:
            return "person.fill.questionmark"
        case .absences:
            return "calendar.badge.exclamationmark"
        case .advisory:
            return "bubble.left.and.bubble.right.fill"
        case .grievance:
            return "exclamationmark.triangle.fill"
        case .other:
            return "ellipsis.circle.fill"
        }
    }

    var description: String {
        switch self {
        case .academicPerformance:
            return "Discuss grades, coursework, and academic progress"
        case .studentBehavior:
            return "Address behavioral concerns or achievements"
        case .absences:
            return "Discuss attendance issues or planned absences"
        case .advisory:
            return "General guidance and counseling"
        case .grievance:
            return "Report complaints or concerns"
        case .other:
            return "Other topics not listed above"
        }
    }
}
