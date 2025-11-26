import SwiftUI

extension Color {
    // Primary brand colors (based on the design screenshot)
    static let primaryBlue = Color(red: 0.0, green: 0.478, blue: 1.0) // #007AFF
    static let secondaryBlue = Color(red: 0.2, green: 0.6, blue: 1.0) // Light blue
    static let accentRed = Color(red: 1.0, green: 0.231, blue: 0.188) // #FF3B30

    // Background colors
    static let backgroundPrimary = Color(UIColor.systemBackground)
    static let backgroundSecondary = Color(UIColor.secondarySystemBackground)
    static let backgroundTertiary = Color(UIColor.tertiarySystemBackground)

    // Card backgrounds
    static let cardBackground = Color(UIColor.secondarySystemGroupedBackground)
    static let highlightedCardBackground = Color(red: 0.9, green: 0.95, blue: 1.0) // Light blue tint

    // Text colors
    static let textPrimary = Color(UIColor.label)
    static let textSecondary = Color(UIColor.secondaryLabel)
    static let textTertiary = Color(UIColor.tertiaryLabel)

    // Separator
    static let separator = Color(UIColor.separator)

    // Status colors
    static let statusPending = Color.orange
    static let statusApproved = Color.green
    static let statusRejected = Color.red
}

extension View {
    func cardStyle() -> some View {
        self
            .background(Color.cardBackground)
            .cornerRadius(12)
            .shadow(color: Color.black.opacity(0.05), radius: 5, x: 0, y: 2)
    }

    func primaryButtonStyle() -> some View {
        self
            .font(.headline)
            .foregroundColor(.white)
            .frame(maxWidth: .infinity)
            .padding()
            .background(Color.primaryBlue)
            .cornerRadius(12)
    }

    func secondaryButtonStyle() -> some View {
        self
            .font(.headline)
            .foregroundColor(.primaryBlue)
            .frame(maxWidth: .infinity)
            .padding()
            .background(Color.primaryBlue.opacity(0.1))
            .cornerRadius(12)
    }
}
