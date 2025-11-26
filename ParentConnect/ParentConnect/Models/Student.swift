import Foundation

struct Student: Identifiable, Codable, Hashable {
    let id: String
    let name: String
    let grade: String
    let schoolId: String
    let schoolName: String
    let photoURL: String?

    static func == (lhs: Student, rhs: Student) -> Bool {
        lhs.id == rhs.id
    }

    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
}
