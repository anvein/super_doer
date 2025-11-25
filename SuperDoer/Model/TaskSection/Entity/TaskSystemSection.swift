/// Системный список задач
/// Не хранятся в БД, поэтому для них обычный класс
final class TaskSystemSection: TaskSectionProtocol {

    var type: TaskSystemSectionType
    var title: String
    var tasksCount: Int

    init(type: TaskSystemSectionType, title: String, tasksCount: Int = 0) {
        self.type = type
        self.title = title
        self.tasksCount = tasksCount
    }
}
