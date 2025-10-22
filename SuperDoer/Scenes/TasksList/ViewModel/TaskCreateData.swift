import Foundation

struct TaskCreateData {
    let title: String
    var inMyDay: Bool = false
    var reminderDateTime: Date? = nil
    var deadlineAt: Date? = nil
    var description: String? = nil
}
