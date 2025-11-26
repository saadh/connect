import Foundation

struct Parent: Identifiable, Codable {
    let id: String
    let name: String
    let email: String
    let phoneNumber: String
    let photoURL: String?
    let studentIds: [String]

    var formattedPhoneNumber: String {
        return phoneNumber
    }
}
