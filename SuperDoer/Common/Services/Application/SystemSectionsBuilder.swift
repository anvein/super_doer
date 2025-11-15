import UIKit

class SystemSectionsBuilder {
    func buildSections() -> [TaskSystemSection] {
        // TODO: предусмотреть, чтобы в случае скрывания списков они не создавались (настройки брать в UserDefaults)

        var systemSections = [TaskSystemSection]()
        systemSections.append(
            TaskSystemSection(type: .myDay, title: "Мой день")
        )

        systemSections.append(
            TaskSystemSection(type: .important, title: "Важно")
        )

        systemSections.append(
            TaskSystemSection(type: .planned, title: "Запланировано")
        )

        systemSections.append(
            TaskSystemSection(type: .all, title: "Все")
        )

        systemSections.append(
            TaskSystemSection(type: .completed, title: "Завершенные")
        )

        systemSections.append(
            TaskSystemSection(type: .withoutSection, title: "Задачи")
        )

        return systemSections
    }
}
