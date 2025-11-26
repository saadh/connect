import SwiftUI

struct ConfirmationView: View {
    @EnvironmentObject var viewModel: AppointmentViewModel

    var body: some View {
        VStack(alignment: .leading, spacing: 20) {
            // Header
            VStack(alignment: .leading, spacing: 8) {
                Text("Review your appointment request")
                    .font(.headline)
                    .foregroundColor(.textPrimary)

                Text("Please review the details below before submitting your request.")
                    .font(.subheadline)
                    .foregroundColor(.textSecondary)
            }

            // Appointment Summary Card
            VStack(spacing: 0) {
                // Student Section
                ConfirmationRow(
                    icon: "person.fill",
                    title: "Student",
                    value: viewModel.selectedStudent?.name ?? "Not selected",
                    subtitle: viewModel.selectedStudent?.grade
                )

                Divider()
                    .padding(.horizontal, 16)

                // Representative Section
                ConfirmationRow(
                    icon: "person.crop.circle.badge.checkmark",
                    title: "Meeting With",
                    value: viewModel.selectedRepresentative?.name ?? "Not selected",
                    subtitle: viewModel.selectedRepresentative?.title.displayName
                )

                Divider()
                    .padding(.horizontal, 16)

                // Date & Time Section
                ConfirmationRow(
                    icon: "calendar",
                    title: "Date & Time",
                    value: viewModel.selectedDate.fullDateString,
                    subtitle: "\(viewModel.selectedTime.timeString) (\(viewModel.selectedDuration.fullDescription))"
                )

                Divider()
                    .padding(.horizontal, 16)

                // Category Section
                ConfirmationRow(
                    icon: "folder.fill",
                    title: "Category",
                    value: viewModel.selectedCategory?.displayName ?? "Not selected",
                    subtitle: nil
                )

                Divider()
                    .padding(.horizontal, 16)

                // Purpose Section
                VStack(alignment: .leading, spacing: 8) {
                    HStack(spacing: 12) {
                        Image(systemName: "text.alignleft")
                            .foregroundColor(.primaryBlue)
                            .frame(width: 24)

                        Text("Purpose")
                            .font(.subheadline)
                            .foregroundColor(.textSecondary)
                    }

                    Text(viewModel.purpose)
                        .font(.body)
                        .foregroundColor(.textPrimary)
                        .padding(.leading, 36)
                }
                .padding(16)
            }
            .background(Color.backgroundPrimary)
            .cornerRadius(12)

            // School Info
            if let student = viewModel.selectedStudent {
                HStack(spacing: 8) {
                    Image(systemName: "building.2.fill")
                        .foregroundColor(.primaryBlue)

                    Text(student.schoolName)
                        .font(.subheadline)
                        .foregroundColor(.textSecondary)
                }
                .padding(12)
                .frame(maxWidth: .infinity, alignment: .leading)
                .background(Color.primaryBlue.opacity(0.05))
                .cornerRadius(8)
            }

            // Notice
            noticeSection

            Spacer()
        }
    }

    // MARK: - Notice Section
    private var noticeSection: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack(spacing: 8) {
                Image(systemName: "info.circle.fill")
                    .foregroundColor(.orange)
                Text("What happens next?")
                    .font(.subheadline)
                    .fontWeight(.semibold)
                    .foregroundColor(.textPrimary)
            }

            VStack(alignment: .leading, spacing: 6) {
                NoticeRow(
                    number: "1",
                    text: "Your request will be sent to \(viewModel.selectedRepresentative?.name ?? "the representative")"
                )
                NoticeRow(
                    number: "2",
                    text: "You will receive a notification when your request is reviewed"
                )
                NoticeRow(
                    number: "3",
                    text: "If approved, you'll get a confirmation with meeting details"
                )
            }
        }
        .padding(16)
        .background(Color.orange.opacity(0.05))
        .cornerRadius(12)
    }
}

struct ConfirmationRow: View {
    let icon: String
    let title: String
    let value: String
    let subtitle: String?

    var body: some View {
        HStack(alignment: .top, spacing: 12) {
            Image(systemName: icon)
                .foregroundColor(.primaryBlue)
                .frame(width: 24)

            VStack(alignment: .leading, spacing: 4) {
                Text(title)
                    .font(.subheadline)
                    .foregroundColor(.textSecondary)

                Text(value)
                    .font(.body)
                    .fontWeight(.medium)
                    .foregroundColor(.textPrimary)

                if let subtitle = subtitle {
                    Text(subtitle)
                        .font(.caption)
                        .foregroundColor(.textTertiary)
                }
            }

            Spacer()
        }
        .padding(16)
    }
}

struct NoticeRow: View {
    let number: String
    let text: String

    var body: some View {
        HStack(alignment: .top, spacing: 12) {
            Text(number)
                .font(.caption)
                .fontWeight(.bold)
                .foregroundColor(.white)
                .frame(width: 20, height: 20)
                .background(Color.orange)
                .clipShape(Circle())

            Text(text)
                .font(.caption)
                .foregroundColor(.textSecondary)
        }
    }
}

#Preview {
    ConfirmationView()
        .environmentObject(AppointmentViewModel())
        .padding()
        .background(Color.backgroundSecondary)
}
