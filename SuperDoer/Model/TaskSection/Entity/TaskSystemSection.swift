enum TaskSystemSection: TaskSectionProtocol {
    case myDay
    case important
    case planned
    case all
    case completed
    case withoutSection

    var fullTitle: String {
        switch self {
        case .myDay: "Мой день"
        case .important: "Важные"
        case .planned: "Запланировано"
        case .all: "Все"
        case .completed: "Завершенные"
        case .withoutSection: "Новые"
        }
    }
}
