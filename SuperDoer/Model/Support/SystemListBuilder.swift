
import UIKit

class SystemListBuilder {
    func buildLists() -> [TaskSectionSystem] {
        // TODO: предусмотреть, чтобы в случае скрывания списков они не создавались (настройки брать в UserDefaults)
        
        var systemSections = [TaskSectionSystem]()
        systemSections.append(
            TaskSectionSystem(type: .myDay, title: "Мой день")
        )
        
        systemSections.append(
            TaskSectionSystem(type: .important, title: "Важно")
        )
        
        systemSections.append(
            TaskSectionSystem(type: .planned, title: "Запланировано")
        )
        
        systemSections.append(
            TaskSectionSystem(type: .all, title: "Все")
        )
        
        systemSections.append(
            TaskSectionSystem(type: .completed, title: "Завершенные")
        )
        
        systemSections.append(
            TaskSectionSystem(type: .withoutSection, title: "Задачи")
        )
        
        return systemSections
    }
}
