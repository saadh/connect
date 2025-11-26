import Foundation

struct School: Identifiable, Codable, Hashable {
    let id: String
    let name: String
    let address: String
    let logoURL: String?

    static func == (lhs: School, rhs: School) -> Bool {
        lhs.id == rhs.id
    }

    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
}
