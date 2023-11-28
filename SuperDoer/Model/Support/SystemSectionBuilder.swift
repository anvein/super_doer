
import UIKit

class SystemSectionBuilder {
    func buildSections() -> [SystemSection] {
        // TODO: предусмотреть, чтобы в случае скрывания списков они не создавались (настройки брать в UserDefaults)
        
        var systemSections = [SystemSection]()
        systemSections.append(
            SystemSection(type: .myDay, title: "Мой день")
        )
        
        systemSections.append(
            SystemSection(type: .important, title: "Важно")
        )
        
        systemSections.append(
            SystemSection(type: .planned, title: "Запланировано")
        )
        
        systemSections.append(
            SystemSection(type: .all, title: "Все")
        )
        
        systemSections.append(
            SystemSection(type: .completed, title: "Завершенные")
        )
        
        systemSections.append(
            SystemSection(type: .withoutSection, title: "Задачи")
        )
        
        return systemSections
    }
}

// MARK: model
struct SystemSection {
    enum SectionType {
        case myDay
        case important
        case planned
        case all
        case completed
        case withoutSection
    }
    
    var type: SectionType
    var title: String
    var tasksCount: Int?
}
