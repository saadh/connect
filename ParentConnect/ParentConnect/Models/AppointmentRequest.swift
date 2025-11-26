import Foundation

struct AppointmentRequest: Identifiable, Codable, Hashable {
    let id: String
    let studentId: String
    let representativeId: String
    let date: Date
    let time: Date
    let duration: AppointmentDuration
    let category: AppointmentCategory
    let purpose: String
    var status: AppointmentStatus
    let createdAt: Date
    var updatedAt: Date

    var studentName: String?
    var representativeName: String?
    var representativeTitle: RepresentativeTitle?
    var schoolName: String?

    var formattedDate: String {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        return formatter.string(from: date)
    }

    var formattedTime: String {
        let formatter = DateFormatter()
        formatter.timeStyle = .short
        return formatter.string(from: time)
    }

    var formattedDateTime: String {
        return "\(formattedDate) at \(formattedTime)"
    }

    static func == (lhs: AppointmentRequest, rhs: AppointmentRequest) -> Bool {
        lhs.id == rhs.id
    }

    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }

    init(
        id: String = UUID().uuidString,
        studentId: String,
        representativeId: String,
        date: Date,
        time: Date,
        duration: AppointmentDuration,
        category: AppointmentCategory,
        purpose: String,
        status: AppointmentStatus = .pending,
        createdAt: Date = Date(),
        updatedAt: Date = Date(),
        studentName: String? = nil,
        representativeName: String? = nil,
        representativeTitle: RepresentativeTitle? = nil,
        schoolName: String? = nil
    ) {
        self.id = id
        self.studentId = studentId
        self.representativeId = representativeId
        self.date = date
        self.time = time
        self.duration = duration
        self.category = category
        self.purpose = purpose
        self.status = status
        self.createdAt = createdAt
        self.updatedAt = updatedAt
        self.studentName = studentName
        self.representativeName = representativeName
        self.representativeTitle = representativeTitle
        self.schoolName = schoolName
    }
}
