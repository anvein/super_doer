
import UIKit

class SystemListBuilder {
    func buildLists() -> [TaskListSystem] {
        // TODO: предусмотреть, чтобы в случае скрывания списков они не создавались (настройки брать в UserDefaults)
        
        var systemSections = [TaskListSystem]()
        systemSections.append(
            TaskListSystem(type: .myDay, title: "Мой день")
        )
        
        systemSections.append(
            TaskListSystem(type: .important, title: "Важно")
        )
        
        systemSections.append(
            TaskListSystem(type: .planned, title: "Запланировано")
        )
        
        systemSections.append(
            TaskListSystem(type: .all, title: "Все")
        )
        
        systemSections.append(
            TaskListSystem(type: .completed, title: "Завершенные")
        )
        
        systemSections.append(
            TaskListSystem(type: .withoutSection, title: "Задачи")
        )
        
        return systemSections
    }
}
