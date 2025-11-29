final class SystemSectionsFactory {
    func buildSections() -> [TaskSystemSection] {
        // сделать фильтрацию секций на основе настроек в CoreData
        var systemSections = [TaskSystemSection]()
        systemSections.append(.myDay)
        systemSections.append(.important)
        systemSections.append(.planned)
        systemSections.append(.all)
        systemSections.append(.completed)
        systemSections.append(.withoutSection)

        return systemSections
    }
}
