import Foundation

enum RepresentativeTitle: String, Codable, CaseIterable {
    case principal = "Principal"
    case vicePrincipal = "Vice Principal"
    case studentAdvisor = "Student Advisor"

    var displayName: String {
        return rawValue
    }

    var icon: String {
        switch self {
        case .principal:
            return "person.crop.circle.badge.checkmark"
        case .vicePrincipal:
            return "person.crop.circle.badge.minus"
        case .studentAdvisor:
            return "person.crop.circle.badge.questionmark"
        }
    }
}

struct SchoolRepresentative: Identifiable, Codable, Hashable {
    let id: String
    let name: String
    let title: RepresentativeTitle
    let schoolId: String
    let photoURL: String?
    let email: String?

    var fullTitle: String {
        return title.displayName
    }

    static func == (lhs: SchoolRepresentative, rhs: SchoolRepresentative) -> Bool {
        lhs.id == rhs.id
    }

    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
}
