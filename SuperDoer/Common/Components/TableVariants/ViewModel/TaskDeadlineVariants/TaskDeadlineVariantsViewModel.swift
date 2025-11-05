import Foundation
import RxCocoa

class TaskDeadlineVariantsViewModel: TableVariantsViewModelType, TaskDeadlineVariantsNavigationEmittable {

    private let variantsFactory: TaskDeadlineVariantsFactory

    // MARK: - State / Rx (Output properties)

    typealias Value = Date
    private var deadlineDate: Value? {
        didSet {
            refreshSelectedVariant(by: deadlineDate)
        }
    }

    private var variantCellViewModels: [BaseVariantCellViewModel]

    private let tableNeedReloadRelay = PublishRelay<Void>()
    var tableNeedReload: Signal<Void> { tableNeedReloadRelay.asSignal() }

    private let isShowReadyButtonRelay = BehaviorRelay<Bool>(value: true)
    var isShowReadyButton: Driver<Bool> { isShowReadyButtonRelay.asDriver() }

    private let isShowDeleteButtonRelay = BehaviorRelay<Bool>(value: false)
    var isShowDeleteButton: Driver<Bool> { isShowDeleteButtonRelay.asDriver() }

    // MARK: - Navigation

    private let navigationEventRelay = PublishRelay<TaskDeadlineVariantsNavigationEvent>()
    var navigationEvent: Signal<TaskDeadlineVariantsNavigationEvent> {
        navigationEventRelay.asSignal()
    }

    // MARK: - Init

    init(deadlineDate: Value?, variantsFactory: TaskDeadlineVariantsFactory) {
        self.variantsFactory = variantsFactory

        variantCellViewModels = variantsFactory.buildCellViewModels()
        refreshSelectedVariant(by: deadlineDate)

        isShowDeleteButtonRelay.accept(deadlineDate != nil)
    }

    // MARK: - UI Actions (Input)

    func didTapSelectVariant(with indexPath: IndexPath) {
        guard let cellVM = getVariantCellViewModel(for: indexPath) else { return }

        switch cellVM {
        case let dateCellVM as DateVariantCellViewModel:
            navigationEventRelay.accept(.didSelectValue(dateCellVM.date))

        case _ as CustomVariantCellViewModel:
            navigationEventRelay.accept(.openCustomDateSetter(deadlineDate))

        default:
            break
        }
    }

    func didTapDelete() {
        navigationEventRelay.accept(.didSelectValue(nil))
    }

    func didTapReady() {
        navigationEventRelay.accept(.didSelectValue(deadlineDate))
    }

    // MARK: - Output methods

    func getCountVariants() -> Int {
        return variantCellViewModels.count
    }

    func getVariantCellViewModel(for indexPath: IndexPath) -> BaseVariantCellViewModel? {
        return variantCellViewModels[safe: indexPath.row]
    }

    // MARK: - Private

    private func refreshSelectedVariant(by deadlineDate: Date?) {
        let selectedIndex = calculateSelectedValueIndex(
            variants: variantCellViewModels,
            deadlineDate: deadlineDate
        )
        
        for (index, variant) in variantCellViewModels.enumerated() {
            variant.isSelected = index == selectedIndex
        }

        tableNeedReloadRelay.accept(())
    }
    
    private func calculateSelectedValueIndex(
        variants: [BaseVariantCellViewModel],
        deadlineDate: Date?
    ) -> Int? {
        guard let deadlineDate else { return nil }

        var resultIndex: Int?
        for (index, variant) in variants.enumerated() {
            guard let variant = variant as? DateVariantCellViewModel else { continue }

            if variant.date.isEqualDate(date2: deadlineDate) {
                resultIndex = index
                break
            }
        }
        
        // если ни один из вариантов не определен как выбранный,
        // но у "Задачи" указан deadlineDate, то выбран последний вариант (кастомный)
        if resultIndex == nil {
            resultIndex = variants.count - 1
        }
        
        return resultIndex
    }

}
