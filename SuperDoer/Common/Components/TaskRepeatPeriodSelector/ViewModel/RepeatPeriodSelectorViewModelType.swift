import RxCocoa

protocol RepeatPeriodSelectorViewModelType {

    // MARK: - Output (properties)

    var isShowReadyButton: Driver<Bool> { get }
    var isShowDaysOfWeek: Driver<Bool> { get }

    var unitSelectedIndex: Driver<Int?> { get }
    var amountSelectedIndex: Driver<Int?> { get }
    var daysOfWeekSelectedIndexes: Driver<Set<Int>> { get }

    // MARK: - Input

    var inputEventRelay: PublishRelay<RepeatPeriodSelectorViewModel.InputEvent> { get }

    // MARK: - Output (methods)

    func getComponentsCount() -> Int
    func getRowsCountInComponent(with index: Int) -> Int
    func getComponentRowTitle(forRow rowIndex: Int, forComponent componentIndex: Int) -> String?
    func getComponentIndex(_ component: RepeatPeriodSelectorViewModel.Component) -> Int
    func getSelectedDaysOfWeekViewModels() -> [RepeatPeriodDayOfWeakViewModel]
}
