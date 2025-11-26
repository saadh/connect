import SwiftUI

struct ProfileView: View {
    @EnvironmentObject var profileViewModel: ProfileViewModel
    @EnvironmentObject var appointmentViewModel: AppointmentViewModel
    @State private var showingScheduleAppointments = false

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 0) {
                    // Header with user info
                    ProfileHeaderView(parent: profileViewModel.parent, studentCount: profileViewModel.studentCount, schoolCount: profileViewModel.schoolCount)

                    // Canteen Banner
                    CanteenBannerView()
                        .padding(.horizontal, 16)
                        .padding(.top, 16)

                    // Menu Items
                    VStack(spacing: 0) {
                        ProfileMenuSection {
                            ProfileMenuItem(
                                icon: "creditcard.fill",
                                title: "My Canteen Wallet",
                                iconColor: .green
                            )

                            ProfileMenuItem(
                                icon: "gearshape.fill",
                                title: "App Settings",
                                iconColor: .gray
                            )

                            ProfileMenuItem(
                                icon: "lock.shield.fill",
                                title: "Permissions",
                                iconColor: .purple
                            )

                            ProfileMenuItem(
                                icon: "arrow.left.arrow.right",
                                title: "Switch Account",
                                iconColor: .blue
                            )

                            ProfileMenuItem(
                                icon: "globe",
                                title: "Change Language",
                                iconColor: .orange
                            )

                            ProfileMenuItem(
                                icon: "key.fill",
                                title: "Change Password",
                                iconColor: .yellow
                            )

                            NavigationLink(destination: ScheduleAppointmentsView()) {
                                ProfileMenuItemContent(
                                    icon: "calendar.badge.plus",
                                    title: "Schedule Appointments",
                                    iconColor: .primaryBlue,
                                    showBadge: appointmentViewModel.appointments.filter { $0.status == .pending }.count > 0,
                                    badgeCount: appointmentViewModel.appointments.filter { $0.status == .pending }.count
                                )
                            }

                            ProfileMenuItem(
                                icon: "trash.fill",
                                title: "Delete Account",
                                iconColor: .red
                            )
                        }
                    }
                    .padding(.top, 16)

                    // Social Media Links
                    SocialMediaLinksView()
                        .padding(.top, 24)
                        .padding(.bottom, 32)

                    // Log Out Button
                    LogOutButtonView()
                        .padding(.horizontal, 16)
                        .padding(.bottom, 32)
                }
            }
            .background(Color.backgroundSecondary)
            .navigationTitle("Account")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button(action: {}) {
                        ZStack(alignment: .topTrailing) {
                            Image(systemName: "headphones.circle.fill")
                                .font(.title2)
                                .foregroundColor(.primaryBlue)
                            Circle()
                                .fill(Color.red)
                                .frame(width: 8, height: 8)
                                .offset(x: 2, y: -2)
                        }
                    }
                }

                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: {}) {
                        Image(systemName: "envelope.fill")
                            .font(.title3)
                            .foregroundColor(.primaryBlue)
                    }
                }
            }
        }
    }
}

struct ProfileHeaderView: View {
    let parent: Parent
    let studentCount: Int
    let schoolCount: Int

    var body: some View {
        VStack(spacing: 0) {
            HStack(spacing: 16) {
                // Profile Image
                ZStack {
                    Circle()
                        .stroke(Color.primaryBlue, lineWidth: 3)
                        .frame(width: 70, height: 70)

                    Image(systemName: "person.circle.fill")
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(width: 60, height: 60)
                        .foregroundColor(.primaryBlue.opacity(0.3))
                        .background(Circle().fill(Color.white))
                        .clipShape(Circle())
                }

                VStack(alignment: .leading, spacing: 4) {
                    HStack(spacing: 8) {
                        Text(parent.name)
                            .font(.title3)
                            .fontWeight(.semibold)
                            .foregroundColor(.textPrimary)

                        Text("(Parent)")
                            .font(.subheadline)
                            .foregroundColor(.textSecondary)
                    }

                    Text(parent.phoneNumber)
                        .font(.subheadline)
                        .foregroundColor(.textSecondary)

                    Text("\(studentCount) Children | \(schoolCount) Schools")
                        .font(.subheadline)
                        .foregroundColor(.primaryBlue)
                }

                Spacer()

                // QR Code Button
                Button(action: {}) {
                    Image(systemName: "qrcode")
                        .font(.title)
                        .foregroundColor(.primaryBlue)
                        .padding(10)
                        .background(Color.primaryBlue.opacity(0.1))
                        .cornerRadius(8)
                }
            }
            .padding(16)
            .background(Color.backgroundPrimary)
        }
    }
}

struct CanteenBannerView: View {
    var body: some View {
        HStack(spacing: 16) {
            // Canteen Icon
            ZStack {
                Image(systemName: "takeoutbag.and.cup.and.straw.fill")
                    .font(.system(size: 40))
                    .foregroundColor(.primaryBlue)
            }
            .frame(width: 60, height: 60)

            VStack(alignment: .leading, spacing: 4) {
                Text("Canteen")
                    .font(.headline)
                    .fontWeight(.semibold)
                    .foregroundColor(.textPrimary)

                Text("Manage balance & pay to your students")
                    .font(.caption)
                    .foregroundColor(.textSecondary)
            }

            Spacer()

            Button(action: {}) {
                Text("Start now")
                    .font(.subheadline)
                    .fontWeight(.semibold)
                    .foregroundColor(.white)
                    .padding(.horizontal, 20)
                    .padding(.vertical, 10)
                    .background(Color.primaryBlue)
                    .cornerRadius(20)
            }
        }
        .padding(16)
        .background(Color.highlightedCardBackground)
        .cornerRadius(16)
    }
}

struct ProfileMenuSection<Content: View>: View {
    let content: Content

    init(@ViewBuilder content: () -> Content) {
        self.content = content()
    }

    var body: some View {
        VStack(spacing: 0) {
            content
        }
        .background(Color.backgroundPrimary)
        .cornerRadius(12)
        .padding(.horizontal, 16)
    }
}

struct ProfileMenuItem: View {
    let icon: String
    let title: String
    let iconColor: Color

    var body: some View {
        Button(action: {}) {
            ProfileMenuItemContent(icon: icon, title: title, iconColor: iconColor)
        }
    }
}

struct ProfileMenuItemContent: View {
    let icon: String
    let title: String
    let iconColor: Color
    var showBadge: Bool = false
    var badgeCount: Int = 0

    var body: some View {
        HStack(spacing: 16) {
            Image(systemName: icon)
                .font(.title3)
                .foregroundColor(iconColor)
                .frame(width: 24, height: 24)

            Text(title)
                .font(.body)
                .foregroundColor(.textPrimary)

            Spacer()

            if showBadge && badgeCount > 0 {
                Text("\(badgeCount)")
                    .font(.caption2)
                    .fontWeight(.semibold)
                    .foregroundColor(.white)
                    .padding(.horizontal, 8)
                    .padding(.vertical, 4)
                    .background(Color.orange)
                    .cornerRadius(10)
            }

            Image(systemName: "chevron.right")
                .font(.caption)
                .foregroundColor(.textTertiary)
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 14)
        .background(Color.backgroundPrimary)
        .overlay(
            Rectangle()
                .fill(Color.separator)
                .frame(height: 0.5),
            alignment: .bottom
        )
    }
}

struct SocialMediaLinksView: View {
    var body: some View {
        HStack(spacing: 24) {
            ForEach(["facebook", "instagram", "twitter", "linkedin", "globe"], id: \.self) { platform in
                Button(action: {}) {
                    Image(systemName: socialMediaIcon(for: platform))
                        .font(.title2)
                        .foregroundColor(.textSecondary)
                }
            }
        }
        .padding(.horizontal, 16)
    }

    private func socialMediaIcon(for platform: String) -> String {
        switch platform {
        case "facebook": return "f.circle.fill"
        case "instagram": return "camera.circle.fill"
        case "twitter": return "bird.fill"
        case "linkedin": return "link.circle.fill"
        case "globe": return "globe"
        default: return "circle"
        }
    }
}

struct LogOutButtonView: View {
    var body: some View {
        Button(action: {}) {
            HStack {
                Image(systemName: "rectangle.portrait.and.arrow.right")
                    .foregroundColor(.red)
                Text("Log Out")
                    .foregroundColor(.red)
                    .fontWeight(.medium)
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, 14)
            .background(Color.backgroundPrimary)
            .cornerRadius(12)
        }
    }
}

#Preview {
    ProfileView()
        .environmentObject(ProfileViewModel())
        .environmentObject(AppointmentViewModel())
}
