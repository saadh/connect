import Foundation

enum AppointmentDuration: Int, Codable, CaseIterable, Identifiable {
    case tenMinutes = 10
    case fifteenMinutes = 15
    case twentyMinutes = 20
    case thirtyMinutes = 30

    var id: Int { rawValue }

    var displayName: String {
        return "\(rawValue) min"
    }

    var fullDescription: String {
        return "\(rawValue) minutes"
    }
}
