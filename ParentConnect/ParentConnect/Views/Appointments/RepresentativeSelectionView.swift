import SwiftUI

struct RepresentativeSelectionView: View {
    @EnvironmentObject var viewModel: AppointmentViewModel

    var body: some View {
        VStack(alignment: .leading, spacing: 20) {
            // Instructions
            VStack(alignment: .leading, spacing: 8) {
                Text("Who would you like to meet with?")
                    .font(.headline)
                    .foregroundColor(.textPrimary)

                Text("Select a school representative from the list below.")
                    .font(.subheadline)
                    .foregroundColor(.textSecondary)
            }

            // Representatives grouped by title
            let groupedReps = viewModel.getRepresentativesByTitle()
            let sortedTitles: [RepresentativeTitle] = [.principal, .vicePrincipal, .studentAdvisor]

            ForEach(sortedTitles, id: \.self) { title in
                if let reps = groupedReps[title], !reps.isEmpty {
                    VStack(alignment: .leading, spacing: 12) {
                        // Section Header
                        HStack(spacing: 8) {
                            Image(systemName: title.icon)
                                .foregroundColor(.primaryBlue)
                            Text(title == .vicePrincipal ? "Vice Principals" :
                                 title == .studentAdvisor ? "Student Advisors" :
                                 title.displayName)
                                .font(.subheadline)
                                .fontWeight(.semibold)
                                .foregroundColor(.textSecondary)
                        }

                        // Representatives
                        ForEach(reps) { representative in
                            RepresentativeCard(
                                representative: representative,
                                isSelected: viewModel.selectedRepresentative?.id == representative.id
                            ) {
                                withAnimation(.easeInOut(duration: 0.2)) {
                                    viewModel.selectRepresentative(representative)
                                }
                                let generator = UIImpactFeedbackGenerator(style: .light)
                                generator.impactOccurred()
                            }
                        }
                    }
                }
            }
        }
    }
}

struct RepresentativeCard: View {
    let representative: SchoolRepresentative
    let isSelected: Bool
    let onTap: () -> Void

    var body: some View {
        Button(action: onTap) {
            HStack(spacing: 16) {
                // Avatar
                ZStack {
                    Circle()
                        .fill(isSelected ? Color.primaryBlue : Color.primaryBlue.opacity(0.1))
                        .frame(width: 50, height: 50)

                    Text(representative.name.prefix(1))
                        .font(.title3)
                        .fontWeight(.semibold)
                        .foregroundColor(isSelected ? .white : .primaryBlue)
                }

                // Info
                VStack(alignment: .leading, spacing: 4) {
                    Text(representative.name)
                        .font(.body)
                        .fontWeight(.medium)
                        .foregroundColor(.textPrimary)

                    Text(representative.title.displayName)
                        .font(.subheadline)
                        .foregroundColor(.textSecondary)

                    if let email = representative.email {
                        Text(email)
                            .font(.caption)
                            .foregroundColor(.textTertiary)
                    }
                }

                Spacer()

                // Selection Indicator
                ZStack {
                    Circle()
                        .stroke(isSelected ? Color.primaryBlue : Color.gray.opacity(0.3), lineWidth: 2)
                        .frame(width: 24, height: 24)

                    if isSelected {
                        Circle()
                            .fill(Color.primaryBlue)
                            .frame(width: 16, height: 16)
                    }
                }
            }
            .padding(16)
            .background(Color.backgroundPrimary)
            .cornerRadius(12)
            .overlay(
                RoundedRectangle(cornerRadius: 12)
                    .stroke(isSelected ? Color.primaryBlue : Color.clear, lineWidth: 2)
            )
        }
        .buttonStyle(PlainButtonStyle())
        .accessibilityLabel("\(representative.name), \(representative.title.displayName)")
        .accessibilityHint(isSelected ? "Selected" : "Double tap to select")
    }
}

#Preview {
    RepresentativeSelectionView()
        .environmentObject(AppointmentViewModel())
        .padding()
        .background(Color.backgroundSecondary)
}
