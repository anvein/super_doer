import Foundation

enum TasksListSection {
    case custom(UUID)
    case system(TaskSystemSection)
}
