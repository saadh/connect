import Foundation
import SwiftUI

@MainActor
class ProfileViewModel: ObservableObject {
    @Published var parent: Parent
    @Published var studentCount: Int
    @Published var schoolCount: Int

    private let dataService = MockDataService.shared

    init() {
        self.parent = dataService.currentParent
        self.studentCount = dataService.students.count

        let uniqueSchools = Set(dataService.students.map { $0.schoolId })
        self.schoolCount = uniqueSchools.count
    }

    func refreshData() {
        parent = dataService.currentParent
        studentCount = dataService.students.count

        let uniqueSchools = Set(dataService.students.map { $0.schoolId })
        schoolCount = uniqueSchools.count
    }
}
