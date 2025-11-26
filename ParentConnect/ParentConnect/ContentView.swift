import SwiftUI

struct ContentView: View {
    @State private var selectedTab = 4 // Default to Profile tab

    var body: some View {
        TabView(selection: $selectedTab) {
            PlaceholderTabView(title: "Pickup", icon: "house.fill")
                .tabItem {
                    Label("Pickup", systemImage: "house.fill")
                }
                .tag(0)

            PlaceholderTabView(title: "Buses", icon: "bus.fill")
                .tabItem {
                    Label("Buses", systemImage: "bus.fill")
                }
                .tag(1)

            PlaceholderTabView(title: "Assistants", icon: "person.2.fill")
                .tabItem {
                    Label("Assistants", systemImage: "person.2.fill")
                }
                .tag(2)

            PlaceholderTabView(title: "Students", icon: "person.3.fill")
                .tabItem {
                    Label("Students", systemImage: "person.3.fill")
                }
                .tag(3)

            ProfileView()
                .tabItem {
                    Label("Account", systemImage: "person.crop.circle.fill")
                }
                .tag(4)
        }
        .tint(.primaryBlue)
    }
}

struct PlaceholderTabView: View {
    let title: String
    let icon: String

    var body: some View {
        NavigationStack {
            VStack(spacing: 20) {
                Image(systemName: icon)
                    .font(.system(size: 60))
                    .foregroundColor(.gray.opacity(0.5))

                Text(title)
                    .font(.title2)
                    .fontWeight(.medium)
                    .foregroundColor(.textSecondary)

                Text("Coming Soon")
                    .font(.subheadline)
                    .foregroundColor(.textTertiary)
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .background(Color.backgroundSecondary)
            .navigationTitle(title)
        }
    }
}

#Preview {
    ContentView()
        .environmentObject(AppointmentViewModel())
        .environmentObject(ProfileViewModel())
}
