import Foundation

struct TaskCreateData {
    let title: String
    var inMyDay = false
    var reminderDateTime: Date?
    var deadlineAt: Date?
    var description: String?
}
