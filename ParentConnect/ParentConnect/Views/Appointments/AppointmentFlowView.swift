import SwiftUI

enum AppointmentFlowStep: Int, CaseIterable {
    case selectRepresentative = 0
    case selectDateTime = 1
    case selectCategory = 2
    case enterPurpose = 3
    case confirmation = 4

    var title: String {
        switch self {
        case .selectRepresentative: return "Select Representative"
        case .selectDateTime: return "Select Date & Time"
        case .selectCategory: return "Select Category"
        case .enterPurpose: return "Meeting Purpose"
        case .confirmation: return "Confirm Request"
        }
    }

    var stepNumber: Int {
        return rawValue + 1
    }

    static var totalSteps: Int {
        return Self.allCases.count
    }
}

struct AppointmentFlowView: View {
    @Environment(\.dismiss) private var dismiss
    @EnvironmentObject var viewModel: AppointmentViewModel
    @State private var currentStep: AppointmentFlowStep = .selectRepresentative
    @State private var showingCancelConfirmation = false

    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                // Progress Indicator
                ProgressIndicatorView(currentStep: currentStep)
                    .padding(.horizontal, 16)
                    .padding(.top, 8)

                // Student Info Header
                if let student = viewModel.selectedStudent {
                    StudentInfoHeader(student: student)
                        .padding(.horizontal, 16)
                        .padding(.top, 16)
                }

                // Step Content
                ScrollView {
                    stepContent
                        .padding(.horizontal, 16)
                        .padding(.vertical, 20)
                }

                // Navigation Buttons
                navigationButtons
                    .padding(.horizontal, 16)
                    .padding(.bottom, 16)
            }
            .background(Color.backgroundSecondary)
            .navigationTitle(currentStep.title)
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") {
                        showingCancelConfirmation = true
                    }
                    .foregroundColor(.red)
                }
            }
            .alert("Cancel Appointment?", isPresented: $showingCancelConfirmation) {
                Button("Continue Editing", role: .cancel) {}
                Button("Discard", role: .destructive) {
                    viewModel.resetFlow()
                    dismiss()
                }
            } message: {
                Text("Your appointment request will not be saved.")
            }
            .alert("Success", isPresented: $viewModel.showSuccess) {
                Button("View Status") {
                    viewModel.showSuccess = false
                    dismiss()
                }
            } message: {
                Text(viewModel.successMessage)
            }
            .alert("Error", isPresented: $viewModel.showError) {
                Button("OK", role: .cancel) {
                    viewModel.showError = false
                }
            } message: {
                Text(viewModel.errorMessage)
            }
        }
    }

    // MARK: - Step Content
    @ViewBuilder
    private var stepContent: some View {
        switch currentStep {
        case .selectRepresentative:
            RepresentativeSelectionView()
        case .selectDateTime:
            DateTimeSelectionView()
        case .selectCategory:
            CategorySelectionView()
        case .enterPurpose:
            PurposeEntryView()
        case .confirmation:
            ConfirmationView()
        }
    }

    // MARK: - Navigation Buttons
    private var navigationButtons: some View {
        HStack(spacing: 16) {
            if currentStep != .selectRepresentative {
                Button(action: goBack) {
                    HStack {
                        Image(systemName: "chevron.left")
                        Text("Back")
                    }
                    .secondaryButtonStyle()
                }
            }

            Button(action: goForward) {
                if currentStep == .confirmation {
                    if viewModel.isLoading {
                        ProgressView()
                            .progressViewStyle(CircularProgressViewStyle(tint: .white))
                            .primaryButtonStyle()
                    } else {
                        Text("Send Request")
                            .primaryButtonStyle()
                    }
                } else {
                    HStack {
                        Text("Continue")
                        Image(systemName: "chevron.right")
                    }
                    .primaryButtonStyle()
                }
            }
            .disabled(!canProceed || viewModel.isLoading)
            .opacity(canProceed ? 1.0 : 0.5)
        }
    }

    // MARK: - Navigation Logic
    private var canProceed: Bool {
        switch currentStep {
        case .selectRepresentative:
            return viewModel.selectedRepresentative != nil
        case .selectDateTime:
            return viewModel.canProceedToCategory
        case .selectCategory:
            return viewModel.selectedCategory != nil
        case .enterPurpose:
            return viewModel.canSubmit
        case .confirmation:
            return !viewModel.isLoading
        }
    }

    private func goBack() {
        withAnimation {
            if let previousStep = AppointmentFlowStep(rawValue: currentStep.rawValue - 1) {
                currentStep = previousStep
            }
        }
        let generator = UIImpactFeedbackGenerator(style: .light)
        generator.impactOccurred()
    }

    private func goForward() {
        if currentStep == .confirmation {
            Task {
                await viewModel.submitAppointment()
            }
        } else {
            withAnimation {
                if let nextStep = AppointmentFlowStep(rawValue: currentStep.rawValue + 1) {
                    currentStep = nextStep
                }
            }
            let generator = UIImpactFeedbackGenerator(style: .light)
            generator.impactOccurred()
        }
    }
}

// MARK: - Progress Indicator
struct ProgressIndicatorView: View {
    let currentStep: AppointmentFlowStep

    var body: some View {
        VStack(spacing: 8) {
            HStack(spacing: 4) {
                ForEach(AppointmentFlowStep.allCases, id: \.rawValue) { step in
                    Rectangle()
                        .fill(step.rawValue <= currentStep.rawValue ? Color.primaryBlue : Color.gray.opacity(0.3))
                        .frame(height: 4)
                        .cornerRadius(2)
                }
            }

            Text("Step \(currentStep.stepNumber) of \(AppointmentFlowStep.totalSteps)")
                .font(.caption)
                .foregroundColor(.textSecondary)
        }
    }
}

// MARK: - Student Info Header
struct StudentInfoHeader: View {
    let student: Student

    var body: some View {
        HStack(spacing: 12) {
            ZStack {
                Circle()
                    .fill(Color.primaryBlue.opacity(0.1))
                    .frame(width: 44, height: 44)

                Text(student.name.prefix(1))
                    .font(.headline)
                    .foregroundColor(.primaryBlue)
            }

            VStack(alignment: .leading, spacing: 2) {
                Text(student.name)
                    .font(.subheadline)
                    .fontWeight(.medium)
                    .foregroundColor(.textPrimary)

                Text("\(student.grade) - \(student.schoolName)")
                    .font(.caption)
                    .foregroundColor(.textSecondary)
            }

            Spacer()
        }
        .padding(12)
        .background(Color.backgroundPrimary)
        .cornerRadius(12)
    }
}

#Preview {
    AppointmentFlowView()
        .environmentObject(AppointmentViewModel())
}
