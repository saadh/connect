import SwiftUI

enum AppointmentStatus: String, Codable, CaseIterable {
    case pending = "pending"
    case approved = "approved"
    case rejected = "rejected"
    case completed = "completed"
    case cancelled = "cancelled"

    var displayName: String {
        switch self {
        case .pending:
            return "Pending"
        case .approved:
            return "Approved"
        case .rejected:
            return "Rejected"
        case .completed:
            return "Completed"
        case .cancelled:
            return "Cancelled"
        }
    }

    var color: Color {
        switch self {
        case .pending:
            return .orange
        case .approved:
            return .green
        case .rejected:
            return .red
        case .completed:
            return .blue
        case .cancelled:
            return .gray
        }
    }

    var icon: String {
        switch self {
        case .pending:
            return "clock.fill"
        case .approved:
            return "checkmark.circle.fill"
        case .rejected:
            return "xmark.circle.fill"
        case .completed:
            return "checkmark.seal.fill"
        case .cancelled:
            return "minus.circle.fill"
        }
    }

    var isActive: Bool {
        switch self {
        case .pending, .approved:
            return true
        case .rejected, .completed, .cancelled:
            return false
        }
    }
}
