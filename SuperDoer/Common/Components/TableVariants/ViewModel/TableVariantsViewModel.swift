import Foundation
import RxCocoa

final class TableVariantsViewModel<Value, Factory: TableVariantsFactory, Finder: TableVariantSelectedFinder>:
    TableVariantsViewModelInputOutput,
    TableVariantsNavigationEmittable where Factory.CellValueType == Value, Finder.Value == Value {
    typealias NavigationValue = Value

    private let selectedVariantFinder: Finder

    // MARK: - State

    private var value: Value? {
        didSet {
            refreshSelectedVariant(by: value)
        }
    }

    private var variantCellViewModels: [VariantCellViewModel<Value>]

    private let tableNeedReloadRelay = PublishRelay<Void>()
    private let isShowReadyButtonRelay = BehaviorRelay<Bool>(value: true)
    private let isShowDeleteButtonRelay = BehaviorRelay<Bool>(value: false)

    // MARK: - Output

    var isShowDeleteButton: Driver<Bool> { isShowDeleteButtonRelay.asDriver() }
    var isShowReadyButton: Driver<Bool> { isShowReadyButtonRelay.asDriver() }
    var tableNeedReload: Signal<Void> { tableNeedReloadRelay.asSignal() }

    // MARK: - Navigation

    private let navigationEventRelay = PublishRelay<TableVariantsNavigationEvent<Value>>()
    var navigationEvent: Signal<TableVariantsNavigationEvent<Value>> {
        navigationEventRelay.asSignal()
    }

    // MARK: - Init

    init(
        value: Value?,
        variantsFactory: Factory,
        selectedVariantFinder: Finder
    ) {

        self.value = value
        self.selectedVariantFinder = selectedVariantFinder

        variantCellViewModels = variantsFactory.buildCellViewModels()
        refreshSelectedVariant(by: value)

        isShowDeleteButtonRelay.accept(value != nil)
    }

    // MARK: - UI Actions (Input)

    func didTapSelectVariant(with indexPath: IndexPath) {
        guard let cellVM = getVariantCellViewModel(for: indexPath) else { return }

        switch cellVM {
        case _ as CustomVariantCellViewModel<Value>:
            navigationEventRelay.accept(.didSelectCustomVariant(value))

        case let variantCellVM as VariantCellViewModel<Value>:
            navigationEventRelay.accept(.didSelectValue(variantCellVM.value))

        default:
            break
        }
    }

    func didTapDelete() {
        navigationEventRelay.accept(.didSelectValue(nil))
    }

    func didTapReady() {
        navigationEventRelay.accept(.didSelectValue(value))
    }

    // MARK: - Output methods

    func getCountVariants() -> Int {
        return variantCellViewModels.count
    }

    func getVariantCellViewModel(for indexPath: IndexPath) -> VariantCellViewModelProtocol? {
        return variantCellViewModels[safe: indexPath.row]
    }

    // MARK: - Private

    private func refreshSelectedVariant(by value: Value?) {
        let selectedIndex = selectedVariantFinder.findSelectedIndex(
            of: value,
            in: variantCellViewModels
        )

        for (index, variant) in variantCellViewModels.enumerated() {
            variant.isSelected = index == selectedIndex
        }

        tableNeedReloadRelay.accept(())
    }

}
