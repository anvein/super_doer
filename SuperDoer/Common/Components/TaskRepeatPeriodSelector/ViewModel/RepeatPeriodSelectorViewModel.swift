import Foundation
import RxCocoa
import RxSwift

final class RepeatPeriodSelectorViewModel: RepeatPeriodSelectorViewModelType, RepeatPeriodSelectorNavigationEmittable {

    enum InputEvent {
        case onChangedPickerValue(rowIndex: Int, componentIndex: Int)
        case didTapDayOfWeek(RepeatPeriodDayOfWeakViewModel)
        case didTapReadyButton
    }

    enum Component: Int, CaseIterable {
        case amount
        case unit
    }

    struct ComponentsData {
        let amount: [Int]
        let unit: [TaskRepeatPeriodUnit]
        let daysOfWeak: [DayOfWeek]

        static let defaultAmount: Int = 1
        static let defaultUnit: TaskRepeatPeriodUnit = .day
    }

    private let disposeBag = DisposeBag()

    // MARK: - State

    private let componentsData: ComponentsData
    private var repeatPeriodRelay = BehaviorRelay<TaskRepeatPeriod?>(value: nil)

    private let isShowReadyButtonRelay = BehaviorRelay<Bool>(value: true)
    private let isShowDaysOfWeakRelay = BehaviorRelay<Bool>(value: false)

    private let unitSelectedIndexRelay = BehaviorRelay<Int?>(value: nil)
    private let amountSelectedIndexRelay = BehaviorRelay<Int?>(value: nil)
    private let daysOfWeekSelectedIndexesRelay = BehaviorRelay<Set<Int>>(value: [])

    // MARK: - Output (properties)

    var isShowReadyButton: Driver<Bool> { isShowReadyButtonRelay.asDriver() }
    var isShowDaysOfWeek: Driver<Bool> { isShowDaysOfWeakRelay.asDriver() }

    var unitSelectedIndex: Driver<Int?> {
        unitSelectedIndexRelay.distinctUntilChanged().asDriver(onErrorJustReturn: nil)
    }
    var amountSelectedIndex: Driver<Int?> {
        amountSelectedIndexRelay.distinctUntilChanged().asDriver(onErrorJustReturn: nil)
    }
    var daysOfWeekSelectedIndexes: Driver<Set<Int>> {
        daysOfWeekSelectedIndexesRelay.distinctUntilChanged().asDriver(onErrorJustReturn: [])
    }

    // MARK: - Input

    var inputEventRelay = PublishRelay<InputEvent>()

    // MARK: - Navigation

    var navigationEvent = PublishRelay<RepeatPeriodSelectorNavigationEvent>()

    // MARK: - Init

    init(repeatPeriod: TaskRepeatPeriod?) {
        self.componentsData = Self.buildComponentsData()
        self.repeatPeriodRelay.accept(repeatPeriod)

        setupBindings()
    }

    private func setupBindings() {
        // V -> VM
        inputEventRelay.subscribe(onNext: { [weak self] event in
            self?.handleInputEvent(event)
        })
        .disposed(by: disposeBag)

        // internal
        repeatPeriodRelay.subscribe(onNext: { [weak self] repeatPeriod in
            self?.handleDidUpdatedRepeatPeriod(repeatPeriod)
        })
        .disposed(by: disposeBag)
    }

    private static func buildComponentsData() -> ComponentsData {
        return .init(
            amount: Array(1...999),
            unit: TaskRepeatPeriodUnit.allCases,
            daysOfWeak: DayOfWeek.allCases
        )
    }

    // MARK: - Output (methods)

    func getComponentsCount() -> Int {
        return Component.allCases.count
    }

    func getRowsCountInComponent(with index: Int) -> Int {
        switch index {
        case Component.amount.rawValue: componentsData.amount.count
        case Component.unit.rawValue: componentsData.unit.count
        default:  0
        }
    }

    func getComponentRowTitle(forRow rowIndex: Int, forComponent componentIndex: Int) -> String? {
        switch componentIndex {
        case Component.amount.rawValue:
            return componentsData.amount[safe: rowIndex].map { String($0) }

        case Component.unit.rawValue:
            return componentsData.unit[safe: rowIndex]?.title

        default:
            return nil
        }
    }

    func getComponentIndex(_ component: Component) -> Int {
        component.rawValue
    }

    func getDaysOfWeekData() -> [RepeatPeriodDayOfWeakViewModel] {
        let selectedValuesIndexes = daysOfWeekSelectedIndexesRelay.value
        var result = [RepeatPeriodDayOfWeakViewModel]()
        for (index, value) in componentsData.daysOfWeak.enumerated() {
            result.append(
                .init(
                    index: index,
                    title: value.shortTitle,
                    isSelected: selectedValuesIndexes.contains(index)
                )
            )
        }

        return result
    }

    // MARK: - Actions handlers

    private func handleInputEvent(_ event: InputEvent) {
        switch event {
        case .onChangedPickerValue(let rowIndex, let componentIndex):
            handleOnChangedPickerValue(rowIndex: rowIndex, componentIndex: componentIndex)

        case .didTapReadyButton:
            navigationEvent.accept(.didSelectValue(repeatPeriodRelay.value))

        case .didTapDayOfWeek(let dayOfWeekVM):
            handleDidTapDayOfWeek(dayOfWeekVM)
        }
    }

    private func handleDidTapDayOfWeek(_ dayOfWeekVM: RepeatPeriodDayOfWeakViewModel) {
        guard let tappedDayOfWeek = componentsData.daysOfWeak[safe: dayOfWeekVM.index] else { return }

        var daysOfWeek = repeatPeriodRelay.value?.daysOfWeek ?? .init()

        if dayOfWeekVM.isSelected {
            daysOfWeek.insert(tappedDayOfWeek)
        } else {
            daysOfWeek.remove(tappedDayOfWeek)
        }

        let newValue = calculateRepeatPeriodForChanged(
            currentRepeatPeriod: repeatPeriodRelay.value,
            newAmount: nil,
            newUnit: nil,
            newDaysOfWeek: daysOfWeek
        )

        repeatPeriodRelay.accept(newValue)
    }

    private func handleOnChangedPickerValue(rowIndex: Int, componentIndex: Int) {
        guard let component = Component(rawValue: componentIndex) else { return }

        var newAmount: Int?
        var newUnit: TaskRepeatPeriodUnit?

        switch component {
        case .amount:
            newAmount = componentsData.amount[safe: rowIndex]

        case .unit:
            newUnit = componentsData.unit[safe: rowIndex]
        }

        let newValue = calculateRepeatPeriodForChanged(
            currentRepeatPeriod: repeatPeriodRelay.value,
            newAmount: newAmount,
            newUnit: newUnit,
            newDaysOfWeek: nil
        )

        repeatPeriodRelay.accept(newValue)
    }

    private func handleDidUpdatedRepeatPeriod(_ repeatPeriod: TaskRepeatPeriod?) {
        let amountIndex = componentsData.amount.firstIndex { $0 == repeatPeriod?.amount }
        amountSelectedIndexRelay.accept(amountIndex)

        let unitIndex = componentsData.unit.firstIndex { $0 == repeatPeriod?.unit }
        unitSelectedIndexRelay.accept(unitIndex)

        let daysOfWeakIndexes = componentsData.daysOfWeak.enumerated()
            .compactMap { (index, element) in
                repeatPeriod?.daysOfWeek.contains(element) == true ? index : nil
            }
        daysOfWeekSelectedIndexesRelay.accept(Set(daysOfWeakIndexes))

        let needShowDaysOfWeak = repeatPeriod?.unit == .week
        isShowDaysOfWeakRelay.accept(needShowDaysOfWeak)
    }

    // MARK: - Helpers

    private func calculateRepeatPeriodForChanged(
        currentRepeatPeriod: TaskRepeatPeriod? = nil,
        newAmount: Int? = nil,
        newUnit: TaskRepeatPeriodUnit? = nil,
        newDaysOfWeek: Set<DayOfWeek>? = nil
    ) -> TaskRepeatPeriod {
        var newRepeatPeriod: TaskRepeatPeriod
        if let currentRepeatPeriod {
            newRepeatPeriod = currentRepeatPeriod
        } else {
            newRepeatPeriod = .init(
                unit: ComponentsData.defaultUnit,
                amount: ComponentsData.defaultAmount,
                daysOfWeek: .init()
            )
        }

        if let newAmount {
            newRepeatPeriod.amount = newAmount
        }

        if let newUnit {
            newRepeatPeriod.unit = newUnit
            if newUnit != .week {
                newRepeatPeriod.daysOfWeek = .init()
            }
        }

        if let newDaysOfWeek {
            newRepeatPeriod.daysOfWeek = newDaysOfWeek
        }

        return newRepeatPeriod
    }

}
