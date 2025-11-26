import SwiftUI

@main
struct ParentConnectApp: App {
    @StateObject private var appointmentViewModel = AppointmentViewModel()
    @StateObject private var profileViewModel = ProfileViewModel()

    init() {
        setupAppearance()
        setupNotifications()
    }

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(appointmentViewModel)
                .environmentObject(profileViewModel)
        }
    }

    private func setupAppearance() {
        // Tab bar appearance
        let tabBarAppearance = UITabBarAppearance()
        tabBarAppearance.configureWithOpaqueBackground()
        tabBarAppearance.backgroundColor = UIColor.systemBackground
        UITabBar.appearance().standardAppearance = tabBarAppearance
        UITabBar.appearance().scrollEdgeAppearance = tabBarAppearance

        // Navigation bar appearance
        let navBarAppearance = UINavigationBarAppearance()
        navBarAppearance.configureWithOpaqueBackground()
        navBarAppearance.backgroundColor = UIColor.systemBackground
        navBarAppearance.titleTextAttributes = [.foregroundColor: UIColor.label]
        navBarAppearance.largeTitleTextAttributes = [.foregroundColor: UIColor.label]
        UINavigationBar.appearance().standardAppearance = navBarAppearance
        UINavigationBar.appearance().scrollEdgeAppearance = navBarAppearance
        UINavigationBar.appearance().compactAppearance = navBarAppearance
    }

    private func setupNotifications() {
        NotificationService.shared.setupNotificationCategories()
        NotificationService.shared.requestAuthorization { granted in
            print("Notification authorization: \(granted)")
        }
    }
}
