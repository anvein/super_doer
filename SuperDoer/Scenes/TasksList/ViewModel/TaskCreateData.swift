import Foundation

struct TaskCreateData {
    let title: String
    var inMyDay: Bool = false
    var reminderDateTime: Date?
    var deadlineAt: Date?
    var description: String?
}
