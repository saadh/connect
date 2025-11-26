import SwiftUI

struct CategorySelectionView: View {
    @EnvironmentObject var viewModel: AppointmentViewModel

    var body: some View {
        VStack(alignment: .leading, spacing: 20) {
            // Instructions
            VStack(alignment: .leading, spacing: 8) {
                Text("What's the meeting about?")
                    .font(.headline)
                    .foregroundColor(.textPrimary)

                Text("Select the category that best describes the purpose of your meeting.")
                    .font(.subheadline)
                    .foregroundColor(.textSecondary)
            }

            // Category Options
            VStack(spacing: 12) {
                ForEach(AppointmentCategory.allCases) { category in
                    CategoryCard(
                        category: category,
                        isSelected: viewModel.selectedCategory == category
                    ) {
                        withAnimation(.easeInOut(duration: 0.2)) {
                            viewModel.selectCategory(category)
                        }
                        let generator = UIImpactFeedbackGenerator(style: .light)
                        generator.impactOccurred()
                    }
                }
            }
        }
    }
}

struct CategoryCard: View {
    let category: AppointmentCategory
    let isSelected: Bool
    let onTap: () -> Void

    var body: some View {
        Button(action: onTap) {
            HStack(spacing: 16) {
                // Icon
                ZStack {
                    Circle()
                        .fill(isSelected ? categoryColor.opacity(0.2) : Color.gray.opacity(0.1))
                        .frame(width: 50, height: 50)

                    Image(systemName: category.icon)
                        .font(.title3)
                        .foregroundColor(isSelected ? categoryColor : .textSecondary)
                }

                // Info
                VStack(alignment: .leading, spacing: 4) {
                    Text(category.displayName)
                        .font(.body)
                        .fontWeight(.medium)
                        .foregroundColor(.textPrimary)

                    Text(category.description)
                        .font(.caption)
                        .foregroundColor(.textSecondary)
                        .lineLimit(2)
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
        .accessibilityLabel("\(category.displayName): \(category.description)")
        .accessibilityHint(isSelected ? "Selected" : "Double tap to select")
    }

    private var categoryColor: Color {
        switch category {
        case .academicPerformance:
            return .blue
        case .studentBehavior:
            return .orange
        case .absences:
            return .red
        case .advisory:
            return .purple
        case .grievance:
            return .yellow
        case .other:
            return .gray
        }
    }
}

#Preview {
    CategorySelectionView()
        .environmentObject(AppointmentViewModel())
        .padding()
        .background(Color.backgroundSecondary)
}
