import SwiftUI

struct AppointmentStatusView: View {
    let appointment: AppointmentRequest
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        ScrollView {
            VStack(spacing: 24) {
                // Status Header
                statusHeader

                // Appointment Details Card
                appointmentDetailsCard

                // Timeline
                statusTimeline

                // Actions
                if appointment.status == .approved {
                    actionButtons
                }
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 20)
        }
        .background(Color.backgroundSecondary)
        .navigationTitle("Appointment Details")
        .navigationBarTitleDisplayMode(.inline)
    }

    // MARK: - Status Header
    private var statusHeader: some View {
        VStack(spacing: 16) {
            // Status Icon
            ZStack {
                Circle()
                    .fill(appointment.status.color.opacity(0.1))
                    .frame(width: 80, height: 80)

                Image(systemName: appointment.status.icon)
                    .font(.system(size: 36))
                    .foregroundColor(appointment.status.color)
            }

            // Status Text
            VStack(spacing: 4) {
                Text(statusTitle)
                    .font(.title2)
                    .fontWeight(.bold)
                    .foregroundColor(.textPrimary)

                Text(statusSubtitle)
                    .font(.subheadline)
                    .foregroundColor(.textSecondary)
                    .multilineTextAlignment(.center)
            }
        }
        .frame(maxWidth: .infinity)
        .padding(24)
        .background(Color.backgroundPrimary)
        .cornerRadius(16)
    }

    private var statusTitle: String {
        switch appointment.status {
        case .pending:
            return "Request Pending"
        case .approved:
            return "Appointment Confirmed"
        case .rejected:
            return "Request Declined"
        case .completed:
            return "Appointment Completed"
        case .cancelled:
            return "Appointment Cancelled"
        }
    }

    private var statusSubtitle: String {
        switch appointment.status {
        case .pending:
            return "Your request is being reviewed by \(appointment.representativeName ?? "the representative")"
        case .approved:
            return "Your appointment has been confirmed for \(appointment.formattedDateTime)"
        case .rejected:
            return "Unfortunately, your request could not be accommodated at this time"
        case .completed:
            return "This appointment has been completed"
        case .cancelled:
            return "This appointment was cancelled"
        }
    }

    // MARK: - Appointment Details Card
    private var appointmentDetailsCard: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Appointment Details")
                .font(.headline)
                .foregroundColor(.textPrimary)

            VStack(spacing: 0) {
                DetailRow(icon: "person.fill", label: "Student", value: appointment.studentName ?? "Unknown")
                Divider().padding(.horizontal, 16)

                DetailRow(
                    icon: "person.crop.circle.badge.checkmark",
                    label: "Meeting With",
                    value: appointment.representativeName ?? "Unknown",
                    subtitle: appointment.representativeTitle?.displayName
                )
                Divider().padding(.horizontal, 16)

                DetailRow(icon: "calendar", label: "Date", value: appointment.formattedDate)
                Divider().padding(.horizontal, 16)

                DetailRow(icon: "clock", label: "Time", value: appointment.formattedTime)
                Divider().padding(.horizontal, 16)

                DetailRow(icon: "timer", label: "Duration", value: appointment.duration.fullDescription)
                Divider().padding(.horizontal, 16)

                DetailRow(icon: "folder.fill", label: "Category", value: appointment.category.displayName)
                Divider().padding(.horizontal, 16)

                DetailRow(icon: "building.2.fill", label: "School", value: appointment.schoolName ?? "Unknown")
            }
            .background(Color.backgroundPrimary)
            .cornerRadius(12)

            // Purpose
            VStack(alignment: .leading, spacing: 8) {
                HStack(spacing: 8) {
                    Image(systemName: "text.alignleft")
                        .foregroundColor(.primaryBlue)
                    Text("Purpose")
                        .font(.subheadline)
                        .fontWeight(.medium)
                        .foregroundColor(.textSecondary)
                }

                Text(appointment.purpose)
                    .font(.body)
                    .foregroundColor(.textPrimary)
            }
            .padding(16)
            .background(Color.backgroundPrimary)
            .cornerRadius(12)
        }
    }

    // MARK: - Status Timeline
    private var statusTimeline: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Status History")
                .font(.headline)
                .foregroundColor(.textPrimary)

            VStack(spacing: 0) {
                TimelineItem(
                    icon: "paperplane.fill",
                    title: "Request Submitted",
                    subtitle: formatDate(appointment.createdAt),
                    isCompleted: true,
                    isLast: appointment.status == .pending
                )

                if appointment.status != .pending {
                    TimelineItem(
                        icon: appointment.status == .approved ? "checkmark.circle.fill" : "xmark.circle.fill",
                        title: appointment.status == .approved ? "Request Approved" : "Request Declined",
                        subtitle: formatDate(appointment.updatedAt),
                        isCompleted: true,
                        isLast: true
                    )
                }
            }
            .padding(16)
            .background(Color.backgroundPrimary)
            .cornerRadius(12)
        }
    }

    // MARK: - Action Buttons
    private var actionButtons: some View {
        VStack(spacing: 12) {
            Button(action: {}) {
                HStack {
                    Image(systemName: "calendar.badge.plus")
                    Text("Add to Calendar")
                }
                .primaryButtonStyle()
            }

            Button(action: {}) {
                HStack {
                    Image(systemName: "square.and.arrow.up")
                    Text("Share Details")
                }
                .secondaryButtonStyle()
            }
        }
    }

    // MARK: - Helper Methods
    private func formatDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .short
        return formatter.string(from: date)
    }
}

// MARK: - Detail Row
struct DetailRow: View {
    let icon: String
    let label: String
    let value: String
    var subtitle: String? = nil

    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: icon)
                .foregroundColor(.primaryBlue)
                .frame(width: 24)

            Text(label)
                .font(.subheadline)
                .foregroundColor(.textSecondary)

            Spacer()

            VStack(alignment: .trailing, spacing: 2) {
                Text(value)
                    .font(.body)
                    .foregroundColor(.textPrimary)

                if let subtitle = subtitle {
                    Text(subtitle)
                        .font(.caption)
                        .foregroundColor(.textTertiary)
                }
            }
        }
        .padding(16)
    }
}

// MARK: - Timeline Item
struct TimelineItem: View {
    let icon: String
    let title: String
    let subtitle: String
    let isCompleted: Bool
    let isLast: Bool

    var body: some View {
        HStack(alignment: .top, spacing: 16) {
            // Timeline indicator
            VStack(spacing: 0) {
                ZStack {
                    Circle()
                        .fill(isCompleted ? Color.primaryBlue : Color.gray.opacity(0.3))
                        .frame(width: 32, height: 32)

                    Image(systemName: icon)
                        .font(.caption)
                        .foregroundColor(isCompleted ? .white : .textTertiary)
                }

                if !isLast {
                    Rectangle()
                        .fill(Color.primaryBlue.opacity(0.3))
                        .frame(width: 2, height: 40)
                }
            }

            // Content
            VStack(alignment: .leading, spacing: 4) {
                Text(title)
                    .font(.body)
                    .fontWeight(.medium)
                    .foregroundColor(.textPrimary)

                Text(subtitle)
                    .font(.caption)
                    .foregroundColor(.textSecondary)
            }
            .padding(.top, 4)

            Spacer()
        }
    }
}

#Preview {
    NavigationStack {
        AppointmentStatusView(
            appointment: AppointmentRequest(
                studentId: "1",
                representativeId: "1",
                date: Date(),
                time: Date(),
                duration: .fifteenMinutes,
                category: .academicPerformance,
                purpose: "I would like to discuss my child's academic progress. There are some concerns about math performance.",
                status: .approved,
                studentName: "Ahmed Abdullah",
                representativeName: "Dr. Sarah Hassan",
                representativeTitle: .principal,
                schoolName: "Al Noor International School"
            )
        )
    }
}
