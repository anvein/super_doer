/// В данном случае Group это ViewModel для TableSection
/// Назван Group чтобы не было путаницы с TaskSection
enum SectionsListGroupViewModel: Int, CaseIterable {
    case system = 0
    case custom = 1
}
