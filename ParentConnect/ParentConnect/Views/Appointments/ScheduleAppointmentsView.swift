import SwiftUI

struct ScheduleAppointmentsView: View {
    @EnvironmentObject var viewModel: AppointmentViewModel
    @State private var showingNewAppointment = false

    var body: some View {
        ScrollView {
            VStack(spacing: 20) {
                // Header Section
                headerSection

                // Existing Appointments Section
                if !viewModel.appointments.isEmpty {
                    existingAppointmentsSection
                }

                // Students Section
                studentsSection
            }
            .padding(.bottom, 32)
        }
        .background(Color.backgroundSecondary)
        .navigationTitle("Schedule Appointments")
        .navigationBarTitleDisplayMode(.inline)
        .sheet(isPresented: $showingNewAppointment) {
            AppointmentFlowView()
                .environmentObject(viewModel)
        }
        .onAppear {
            viewModel.refreshAppointments()
        }
    }

    // MARK: - Header Section
    private var headerSection: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Book meetings with school representatives")
                .font(.subheadline)
                .foregroundColor(.textSecondary)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(.horizontal, 16)
        .padding(.top, 8)
    }

    // MARK: - Existing Appointments Section
    private var existingAppointmentsSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Text("Active Appointments")
                    .font(.headline)
                    .foregroundColor(.textPrimary)

                Spacer()

                Text("\(viewModel.appointments.filter { $0.status.isActive }.count)")
                    .font(.subheadline)
                    .fontWeight(.semibold)
                    .foregroundColor(.white)
                    .padding(.horizontal, 10)
                    .padding(.vertical, 4)
                    .background(Color.primaryBlue)
                    .cornerRadius(12)
            }
            .padding(.horizontal, 16)

            ForEach(viewModel.appointments.filter { $0.status.isActive }) { appointment in
                NavigationLink(destination: AppointmentStatusView(appointment: appointment)) {
                    AppointmentCardView(appointment: appointment)
                }
                .buttonStyle(PlainButtonStyle())
            }
            .padding(.horizontal, 16)
        }
    }

    // MARK: - Students Section
    private var studentsSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Select a Student")
                .font(.headline)
                .foregroundColor(.textPrimary)
                .padding(.horizontal, 16)

            ForEach(Array(viewModel.studentsBySchool.keys.sorted()), id: \.self) { schoolName in
                VStack(alignment: .leading, spacing: 8) {
                    // School Header
                    HStack(spacing: 8) {
                        Image(systemName: "building.2.fill")
                            .foregroundColor(.primaryBlue)
                        Text(schoolName)
                            .font(.subheadline)
                            .fontWeight(.semibold)
                            .foregroundColor(.textSecondary)
                    }
                    .padding(.horizontal, 16)

                    // Students in this school
                    if let students = viewModel.studentsBySchool[schoolName] {
                        ForEach(students) { student in
                            StudentCardView(
                                student: student,
                                hasActiveAppointment: viewModel.hasActiveAppointment(for: student.id),
                                activeAppointment: viewModel.getActiveAppointment(for: student.id)
                            ) {
                                viewModel.selectStudent(student)
                                showingNewAppointment = true
                            }
                            .padding(.horizontal, 16)
                        }
                    }
                }
                .padding(.vertical, 8)
            }
        }
    }
}

// MARK: - Student Card View
struct StudentCardView: View {
    let student: Student
    let hasActiveAppointment: Bool
    let activeAppointment: AppointmentRequest?
    let onTap: () -> Void

    var body: some View {
        Button(action: onTap) {
            HStack(spacing: 16) {
                // Student Avatar
                ZStack {
                    Circle()
                        .fill(Color.primaryBlue.opacity(0.1))
                        .frame(width: 56, height: 56)

                    Text(student.name.prefix(1))
                        .font(.title2)
                        .fontWeight(.semibold)
                        .foregroundColor(.primaryBlue)
                }

                VStack(alignment: .leading, spacing: 4) {
                    Text(student.name)
                        .font(.body)
                        .fontWeight(.medium)
                        .foregroundColor(.textPrimary)

                    Text(student.grade)
                        .font(.subheadline)
                        .foregroundColor(.textSecondary)

                    if hasActiveAppointment {
                        HStack(spacing: 4) {
                            Image(systemName: "clock.fill")
                                .font(.caption2)
                            Text("Active request")
                                .font(.caption)
                        }
                        .foregroundColor(.orange)
                    }
                }

                Spacer()

                if hasActiveAppointment {
                    // Show status badge instead of chevron
                    if let appointment = activeAppointment {
                        StatusBadge(status: appointment.status)
                    }
                } else {
                    // Show create button
                    VStack(spacing: 4) {
                        Image(systemName: "calendar.badge.plus")
                            .font(.title3)
                            .foregroundColor(.primaryBlue)
                        Text("Book")
                            .font(.caption2)
                            .foregroundColor(.primaryBlue)
                    }
                }
            }
            .padding(16)
            .background(Color.backgroundPrimary)
            .cornerRadius(12)
            .overlay(
                RoundedRectangle(cornerRadius: 12)
                    .stroke(hasActiveAppointment ? Color.orange.opacity(0.3) : Color.clear, lineWidth: 2)
            )
        }
        .buttonStyle(PlainButtonStyle())
        .disabled(hasActiveAppointment)
        .opacity(hasActiveAppointment ? 0.8 : 1.0)
    }
}

// MARK: - Appointment Card View
struct AppointmentCardView: View {
    let appointment: AppointmentRequest

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text(appointment.studentName ?? "Student")
                        .font(.headline)
                        .foregroundColor(.textPrimary)

                    Text("with \(appointment.representativeName ?? "Representative")")
                        .font(.subheadline)
                        .foregroundColor(.textSecondary)
                }

                Spacer()

                StatusBadge(status: appointment.status)
            }

            Divider()

            HStack(spacing: 16) {
                HStack(spacing: 6) {
                    Image(systemName: "calendar")
                        .foregroundColor(.primaryBlue)
                    Text(appointment.formattedDate)
                        .font(.subheadline)
                        .foregroundColor(.textSecondary)
                }

                HStack(spacing: 6) {
                    Image(systemName: "clock")
                        .foregroundColor(.primaryBlue)
                    Text(appointment.formattedTime)
                        .font(.subheadline)
                        .foregroundColor(.textSecondary)
                }

                Spacer()

                Text(appointment.duration.displayName)
                    .font(.caption)
                    .foregroundColor(.textTertiary)
                    .padding(.horizontal, 8)
                    .padding(.vertical, 4)
                    .background(Color.backgroundSecondary)
                    .cornerRadius(4)
            }
        }
        .padding(16)
        .background(Color.backgroundPrimary)
        .cornerRadius(12)
    }
}

// MARK: - Status Badge
struct StatusBadge: View {
    let status: AppointmentStatus

    var body: some View {
        HStack(spacing: 4) {
            Image(systemName: status.icon)
                .font(.caption2)
            Text(status.displayName)
                .font(.caption)
                .fontWeight(.medium)
        }
        .foregroundColor(status.color)
        .padding(.horizontal, 10)
        .padding(.vertical, 6)
        .background(status.color.opacity(0.1))
        .cornerRadius(8)
    }
}

#Preview {
    NavigationStack {
        ScheduleAppointmentsView()
            .environmentObject(AppointmentViewModel())
    }
}
