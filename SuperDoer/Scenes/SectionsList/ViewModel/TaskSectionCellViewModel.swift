import UIKit

struct TaskSectionCellViewModel: Hashable {

    enum Icon: Hashable {
        case emoji(String)
        case iconCofig(sfSymbolName: String, color: UIColor, size: Float = 18.5)
    }

    let title: String
    let tasksCount: Int
    let icon: Icon
    let uniqueId: String

    static func build(from customSection: CDTaskCustomSection) -> Self {
        return .init(
            title: customSection.title ?? "",
            tasksCount: Int(customSection.tasksCount),
            icon: buildIcon(for: customSection),
            uniqueId: customSection.id?.uuidString ?? UUID().uuidString
        )
    }

    static func build(from systemSection: TaskSystemSection) -> Self {
        return .init(
            title: systemSection.title,
            tasksCount: 0,
            icon: Self.buildIcon(for: systemSection.type),
            uniqueId: String(systemSection.type.hashValue)
        )
    }

    private static func buildIcon(for systemSectionType: TaskSystemSectionType) -> Icon {
        switch systemSectionType {
        case .myDay:
            return .iconCofig(sfSymbolName: "sun.max", color: .SectionIcons.myDay)
        case .important:
            return .iconCofig(sfSymbolName: "star", color: .SectionIcons.important)
        case .planned:
            return .iconCofig(sfSymbolName: "calendar", color: .SectionIcons.planned)
        case .all:
            return .iconCofig(sfSymbolName: "infinity", color: .SectionIcons.allTasks, size: 17)
        case .completed:
            return .iconCofig(sfSymbolName: "checkmark.circle", color: .SectionIcons.completed)
        case .withoutSection:
            return .iconCofig(sfSymbolName: "tray", color: .SectionIcons.withoutSection)
        }
    }

    private static func buildIcon(for customSection: CDTaskCustomSection) -> Icon {
        return .iconCofig(sfSymbolName: "list.bullet", color: .SectionIcons.default)
    }

    static func == (lhs: TaskSectionCellViewModel, rhs: TaskSectionCellViewModel) -> Bool {
        lhs.uniqueId == rhs.uniqueId
    }
}
