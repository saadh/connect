import SwiftUI

struct DateTimeSelectionView: View {
    @EnvironmentObject var viewModel: AppointmentViewModel
    @State private var showingDatePicker = false

    var body: some View {
        VStack(alignment: .leading, spacing: 24) {
            // Instructions
            VStack(alignment: .leading, spacing: 8) {
                Text("When would you like to meet?")
                    .font(.headline)
                    .foregroundColor(.textPrimary)

                Text("Select a date, time, and duration for your appointment.")
                    .font(.subheadline)
                    .foregroundColor(.textSecondary)
            }

            // Date Selection
            dateSelectionSection

            // Time Selection
            timeSelectionSection

            // Duration Selection
            durationSelectionSection

            // Availability Notice
            availabilityNotice

            // Error Message
            if !viewModel.errorMessage.isEmpty {
                ErrorBanner(message: viewModel.errorMessage)
            }
        }
        .onChange(of: viewModel.selectedDate) { _, _ in
            viewModel.validateDateTime()
        }
        .onChange(of: viewModel.selectedTime) { _, _ in
            viewModel.validateDateTime()
        }
        .onAppear {
            viewModel.validateDateTime()
        }
    }

    // MARK: - Date Selection
    private var dateSelectionSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Label("Date", systemImage: "calendar")
                .font(.subheadline)
                .fontWeight(.semibold)
                .foregroundColor(.textSecondary)

            Button(action: { showingDatePicker.toggle() }) {
                HStack {
                    Text(viewModel.selectedDate.fullDateString)
                        .font(.body)
                        .foregroundColor(.textPrimary)

                    Spacer()

                    Image(systemName: "chevron.down")
                        .foregroundColor(.textSecondary)
                        .rotationEffect(.degrees(showingDatePicker ? 180 : 0))
                }
                .padding(16)
                .background(Color.backgroundPrimary)
                .cornerRadius(12)
            }

            if showingDatePicker {
                DatePicker(
                    "Select Date",
                    selection: $viewModel.selectedDate,
                    in: viewModel.getMinimumDate()...viewModel.getMaximumDate(),
                    displayedComponents: .date
                )
                .datePickerStyle(GraphicalDatePickerStyle())
                .padding()
                .background(Color.backgroundPrimary)
                .cornerRadius(12)
                .onChange(of: viewModel.selectedDate) { _, newDate in
                    // Check if selected date is blocked
                    if viewModel.isWeekendOrBlocked(newDate) {
                        // Find next available date
                        var nextDate = newDate
                        while viewModel.isWeekendOrBlocked(nextDate) {
                            nextDate = Calendar.current.date(byAdding: .day, value: 1, to: nextDate) ?? nextDate
                        }
                        viewModel.selectedDate = nextDate
                    }
                }
            }

            // Quick Date Selection
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 8) {
                    ForEach(getNextAvailableDates(), id: \.self) { date in
                        QuickDateButton(
                            date: date,
                            isSelected: Calendar.current.isDate(date, inSameDayAs: viewModel.selectedDate)
                        ) {
                            viewModel.selectedDate = date
                            let generator = UIImpactFeedbackGenerator(style: .light)
                            generator.impactOccurred()
                        }
                    }
                }
            }
        }
    }

    // MARK: - Time Selection
    private var timeSelectionSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Label("Time", systemImage: "clock")
                .font(.subheadline)
                .fontWeight(.semibold)
                .foregroundColor(.textSecondary)

            LazyVGrid(columns: [
                GridItem(.flexible()),
                GridItem(.flexible()),
                GridItem(.flexible())
            ], spacing: 8) {
                ForEach(viewModel.availableTimeSlots, id: \.self) { timeSlot in
                    TimeSlotButton(
                        time: timeSlot,
                        isSelected: isSameTime(timeSlot, viewModel.selectedTime)
                    ) {
                        viewModel.selectedTime = timeSlot
                        let generator = UIImpactFeedbackGenerator(style: .light)
                        generator.impactOccurred()
                    }
                }
            }
        }
    }

    // MARK: - Duration Selection
    private var durationSelectionSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Label("Duration", systemImage: "timer")
                .font(.subheadline)
                .fontWeight(.semibold)
                .foregroundColor(.textSecondary)

            HStack(spacing: 8) {
                ForEach(AppointmentDuration.allCases, id: \.rawValue) { duration in
                    DurationButton(
                        duration: duration,
                        isSelected: viewModel.selectedDuration == duration
                    ) {
                        viewModel.selectedDuration = duration
                        let generator = UIImpactFeedbackGenerator(style: .light)
                        generator.impactOccurred()
                    }
                }
            }
        }
    }

    // MARK: - Availability Notice
    private var availabilityNotice: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack(spacing: 8) {
                Image(systemName: "info.circle.fill")
                    .foregroundColor(.primaryBlue)
                Text("Availability")
                    .font(.subheadline)
                    .fontWeight(.semibold)
                    .foregroundColor(.textPrimary)
            }

            VStack(alignment: .leading, spacing: 4) {
                Text("Available hours: 7:30 AM - 11:00 AM")
                    .font(.caption)
                    .foregroundColor(.textSecondary)

                Text("No appointments on Fridays & Saturdays")
                    .font(.caption)
                    .foregroundColor(.textSecondary)

                Text("Bookings available for the next 30 days")
                    .font(.caption)
                    .foregroundColor(.textSecondary)
            }
        }
        .padding(16)
        .background(Color.primaryBlue.opacity(0.05))
        .cornerRadius(12)
    }

    // MARK: - Helper Methods
    private func getNextAvailableDates() -> [Date] {
        var dates: [Date] = []
        var currentDate = viewModel.getMinimumDate()
        let maxDate = viewModel.getMaximumDate()

        while dates.count < 7 && currentDate <= maxDate {
            if !viewModel.isWeekendOrBlocked(currentDate) {
                dates.append(currentDate)
            }
            currentDate = Calendar.current.date(byAdding: .day, value: 1, to: currentDate) ?? currentDate
        }

        return dates
    }

    private func isSameTime(_ time1: Date, _ time2: Date) -> Bool {
        let calendar = Calendar.current
        return calendar.component(.hour, from: time1) == calendar.component(.hour, from: time2) &&
               calendar.component(.minute, from: time1) == calendar.component(.minute, from: time2)
    }
}

// MARK: - Quick Date Button
struct QuickDateButton: View {
    let date: Date
    let isSelected: Bool
    let onTap: () -> Void

    var body: some View {
        Button(action: onTap) {
            VStack(spacing: 4) {
                Text(date.isTomorrow ? "Tomorrow" : date.dayOfWeek.prefix(3).uppercased())
                    .font(.caption2)
                    .fontWeight(.medium)

                Text("\(Calendar.current.component(.day, from: date))")
                    .font(.headline)
            }
            .frame(width: 60, height: 60)
            .foregroundColor(isSelected ? .white : .textPrimary)
            .background(isSelected ? Color.primaryBlue : Color.backgroundPrimary)
            .cornerRadius(12)
        }
        .accessibilityLabel(date.fullDateString)
    }
}

// MARK: - Time Slot Button
struct TimeSlotButton: View {
    let time: Date
    let isSelected: Bool
    let onTap: () -> Void

    var body: some View {
        Button(action: onTap) {
            Text(time.timeString)
                .font(.subheadline)
                .fontWeight(isSelected ? .semibold : .regular)
                .foregroundColor(isSelected ? .white : .textPrimary)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 12)
                .background(isSelected ? Color.primaryBlue : Color.backgroundPrimary)
                .cornerRadius(8)
        }
        .accessibilityLabel("Time slot \(time.timeString)")
    }
}

// MARK: - Duration Button
struct DurationButton: View {
    let duration: AppointmentDuration
    let isSelected: Bool
    let onTap: () -> Void

    var body: some View {
        Button(action: onTap) {
            Text(duration.displayName)
                .font(.subheadline)
                .fontWeight(isSelected ? .semibold : .regular)
                .foregroundColor(isSelected ? .white : .textPrimary)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 12)
                .background(isSelected ? Color.primaryBlue : Color.backgroundPrimary)
                .cornerRadius(8)
        }
        .accessibilityLabel("Duration \(duration.fullDescription)")
    }
}

// MARK: - Error Banner
struct ErrorBanner: View {
    let message: String

    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: "exclamationmark.triangle.fill")
                .foregroundColor(.red)

            Text(message)
                .font(.subheadline)
                .foregroundColor(.red)
                .multilineTextAlignment(.leading)

            Spacer()
        }
        .padding(16)
        .background(Color.red.opacity(0.1))
        .cornerRadius(12)
    }
}

#Preview {
    DateTimeSelectionView()
        .environmentObject(AppointmentViewModel())
        .padding()
        .background(Color.backgroundSecondary)
}
