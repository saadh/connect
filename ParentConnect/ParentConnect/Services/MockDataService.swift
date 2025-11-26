import Foundation

class MockDataService {
    static let shared = MockDataService()

    private init() {}

    // MARK: - Schools
    let schools: [School] = [
        School(
            id: "school_1",
            name: "Al Noor International School",
            address: "123 Education Street, City Center",
            logoURL: nil
        ),
        School(
            id: "school_2",
            name: "Emirates Academy",
            address: "456 Learning Avenue, Business Bay",
            logoURL: nil
        )
    ]

    // MARK: - Students
    let students: [Student] = [
        Student(
            id: "student_1",
            name: "Ahmed Abdullah",
            grade: "Grade 5",
            schoolId: "school_1",
            schoolName: "Al Noor International School",
            photoURL: nil
        ),
        Student(
            id: "student_2",
            name: "Fatima Abdullah",
            grade: "Grade 3",
            schoolId: "school_1",
            schoolName: "Al Noor International School",
            photoURL: nil
        ),
        Student(
            id: "student_3",
            name: "Omar Abdullah",
            grade: "Grade 7",
            schoolId: "school_2",
            schoolName: "Emirates Academy",
            photoURL: nil
        )
    ]

    // MARK: - School Representatives
    let representatives: [SchoolRepresentative] = [
        // School 1 Representatives
        SchoolRepresentative(
            id: "rep_1",
            name: "Dr. Sarah Hassan",
            title: .principal,
            schoolId: "school_1",
            photoURL: nil,
            email: "s.hassan@alnoor.edu"
        ),
        SchoolRepresentative(
            id: "rep_2",
            name: "Mr. Khalid Ahmed",
            title: .vicePrincipal,
            schoolId: "school_1",
            photoURL: nil,
            email: "k.ahmed@alnoor.edu"
        ),
        SchoolRepresentative(
            id: "rep_3",
            name: "Ms. Layla Ibrahim",
            title: .vicePrincipal,
            schoolId: "school_1",
            photoURL: nil,
            email: "l.ibrahim@alnoor.edu"
        ),
        SchoolRepresentative(
            id: "rep_4",
            name: "Mr. Hassan Ali",
            title: .studentAdvisor,
            schoolId: "school_1",
            photoURL: nil,
            email: "h.ali@alnoor.edu"
        ),
        SchoolRepresentative(
            id: "rep_5",
            name: "Ms. Nadia Mohammed",
            title: .studentAdvisor,
            schoolId: "school_1",
            photoURL: nil,
            email: "n.mohammed@alnoor.edu"
        ),

        // School 2 Representatives
        SchoolRepresentative(
            id: "rep_6",
            name: "Dr. Mohammed Rashid",
            title: .principal,
            schoolId: "school_2",
            photoURL: nil,
            email: "m.rashid@emirates.edu"
        ),
        SchoolRepresentative(
            id: "rep_7",
            name: "Ms. Aisha Khalifa",
            title: .vicePrincipal,
            schoolId: "school_2",
            photoURL: nil,
            email: "a.khalifa@emirates.edu"
        ),
        SchoolRepresentative(
            id: "rep_8",
            name: "Mr. Yusuf Nasser",
            title: .vicePrincipal,
            schoolId: "school_2",
            photoURL: nil,
            email: "y.nasser@emirates.edu"
        ),
        SchoolRepresentative(
            id: "rep_9",
            name: "Ms. Maryam Sultan",
            title: .studentAdvisor,
            schoolId: "school_2",
            photoURL: nil,
            email: "m.sultan@emirates.edu"
        ),
        SchoolRepresentative(
            id: "rep_10",
            name: "Mr. Faisal Abdullah",
            title: .studentAdvisor,
            schoolId: "school_2",
            photoURL: nil,
            email: "f.abdullah@emirates.edu"
        )
    ]

    // MARK: - Current Parent
    let currentParent = Parent(
        id: "parent_1",
        name: "Allia Abduallah",
        email: "allia.abdullah@email.com",
        phoneNumber: "+1005846588",
        photoURL: nil,
        studentIds: ["student_1", "student_2", "student_3"]
    )

    // MARK: - Existing Appointment Requests (for testing constraints)
    var appointmentRequests: [AppointmentRequest] = []

    func setupInitialAppointments() {
        let calendar = Calendar.current

        // Create a pending appointment for student_1
        let pendingDate = calendar.date(byAdding: .day, value: 5, to: Date()) ?? Date()
        var pendingTime = calendar.date(bySettingHour: 9, minute: 0, second: 0, of: pendingDate) ?? pendingDate

        let pendingAppointment = AppointmentRequest(
            id: "appointment_1",
            studentId: "student_1",
            representativeId: "rep_1",
            date: pendingDate,
            time: pendingTime,
            duration: .fifteenMinutes,
            category: .academicPerformance,
            purpose: "I would like to discuss Ahmed's recent progress in mathematics. He seems to be struggling with fractions and I want to understand how we can support him better at home.",
            status: .pending,
            createdAt: calendar.date(byAdding: .day, value: -2, to: Date()) ?? Date(),
            updatedAt: calendar.date(byAdding: .day, value: -2, to: Date()) ?? Date(),
            studentName: "Ahmed Abdullah",
            representativeName: "Dr. Sarah Hassan",
            representativeTitle: .principal,
            schoolName: "Al Noor International School"
        )

        // Create an approved appointment for student_3
        let approvedDate = calendar.date(byAdding: .day, value: 7, to: Date()) ?? Date()
        let approvedTime = calendar.date(bySettingHour: 10, minute: 30, second: 0, of: approvedDate) ?? approvedDate

        let approvedAppointment = AppointmentRequest(
            id: "appointment_2",
            studentId: "student_3",
            representativeId: "rep_6",
            date: approvedDate,
            time: approvedTime,
            duration: .twentyMinutes,
            category: .advisory,
            purpose: "I need to discuss Omar's college preparation plans. We want to ensure he is on track with his extracurricular activities and coursework for university applications.",
            status: .approved,
            createdAt: calendar.date(byAdding: .day, value: -5, to: Date()) ?? Date(),
            updatedAt: calendar.date(byAdding: .day, value: -3, to: Date()) ?? Date(),
            studentName: "Omar Abdullah",
            representativeName: "Dr. Mohammed Rashid",
            representativeTitle: .principal,
            schoolName: "Emirates Academy"
        )

        appointmentRequests = [pendingAppointment, approvedAppointment]
    }

    // MARK: - Helper Methods
    func getStudentsBySchool() -> [String: [Student]] {
        var grouped: [String: [Student]] = [:]
        for student in students {
            if grouped[student.schoolName] == nil {
                grouped[student.schoolName] = []
            }
            grouped[student.schoolName]?.append(student)
        }
        return grouped
    }

    func getRepresentatives(for schoolId: String) -> [SchoolRepresentative] {
        return representatives.filter { $0.schoolId == schoolId }
    }

    func getStudent(by id: String) -> Student? {
        return students.first { $0.id == id }
    }

    func getRepresentative(by id: String) -> SchoolRepresentative? {
        return representatives.first { $0.id == id }
    }

    func getSchool(by id: String) -> School? {
        return schools.first { $0.id == id }
    }

    func getActiveAppointment(for studentId: String) -> AppointmentRequest? {
        return appointmentRequests.first {
            $0.studentId == studentId && $0.status.isActive
        }
    }

    func hasActiveAppointment(for studentId: String) -> Bool {
        return getActiveAppointment(for: studentId) != nil
    }

    func getAppointmentsThisWeek(for studentId: String) -> [AppointmentRequest] {
        let calendar = Calendar.current
        let now = Date()

        guard let weekStart = calendar.date(from: calendar.dateComponents([.yearForWeekOfYear, .weekOfYear], from: now)),
              let weekEnd = calendar.date(byAdding: .day, value: 7, to: weekStart) else {
            return []
        }

        return appointmentRequests.filter { appointment in
            appointment.studentId == studentId &&
            appointment.createdAt >= weekStart &&
            appointment.createdAt < weekEnd
        }
    }

    func hasAppointmentThisWeek(for studentId: String) -> Bool {
        return !getAppointmentsThisWeek(for: studentId).isEmpty
    }

    func addAppointment(_ appointment: AppointmentRequest) {
        appointmentRequests.append(appointment)
    }

    func getAppointments(for studentId: String) -> [AppointmentRequest] {
        return appointmentRequests.filter { $0.studentId == studentId }
    }

    func getAllAppointments() -> [AppointmentRequest] {
        return appointmentRequests.sorted { $0.createdAt > $1.createdAt }
    }
}
