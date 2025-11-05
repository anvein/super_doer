import Foundation
import RxCocoa

class TaskRepeatPeriodVariantsViewModel: TableVariantsViewModelType {

    // MARK: - State / Rx (Output properties)

    private var repeatPeriod: String? {
        didSet {
            // TODO: когда переделаю на нормальное значение сделать определение выбранного
            //refreshSelectionOfVariantCellValue(fromTask: task)
        }
    }

    private var variantCellViewModels: [BaseVariantCellViewModel]

    private let tableNeedReloadRelay = PublishRelay<Void>()
    var tableNeedReload: Signal<Void> { tableNeedReloadRelay.asSignal() }

    private let isShowReadyButtonRelay = BehaviorRelay<Bool>(value: true)
    var isShowReadyButton: Driver<Bool> { isShowReadyButtonRelay.asDriver() }

    private let isShowDeleteButtonRelay = BehaviorRelay<Bool>(value: false)
    var isShowDeleteButton: Driver<Bool> { isShowDeleteButtonRelay.asDriver() }

    // MARK: - Init

    init(repeatPeriod: String?) {
        self.repeatPeriod = repeatPeriod
        
        variantCellViewModels = Self.buildCellViewModels()

        // TODO: когда переделаю на нормальное значение сделать определение выбранного
        //refreshSelectionOfVariantCellViewModel(fromTask: task)
        isShowDeleteButtonRelay.accept(repeatPeriod != nil)
    }

    // MARK: - UI Actions

    func didTapSelectVariant(with indexPath: IndexPath) {
        print("did select tap with \(indexPath)")
    }

    func didTapDelete() {
        print("did tap delete")
    }

    func didTapReady() {
        print("did tap ready")
    }

    // MARK: - Get data

    func getCountVariants() -> Int {
        return variantCellViewModels.count
    }
    
    func getVariantCellViewModel(for indexPath: IndexPath) -> BaseVariantCellViewModel? {
        return variantCellViewModels[safe: indexPath.row]
    }

    // MARK: - Factory
    // TODO: вынести в фабрику

    private static func buildCellViewModels() -> [BaseVariantCellViewModel] {
        var cellViewModels = [BaseVariantCellViewModel]()
        
        cellViewModels.append(
            TaskRepeatPeriodVariantCellViewModel(
                period: "1day",
                imageSettings: DateVariantCellViewModel.ImageSettings(name: "clock.arrow.circlepath"),
                title: "Каждый день"
            )
        )
        
        let date = Date()
        cellViewModels.append(
            TaskRepeatPeriodVariantCellViewModel(
                period: "1week[wed]",
                imageSettings: DateVariantCellViewModel.ImageSettings(name: "square.grid.3x1.below.line.grid.1x2.fill"),
                title: "Каждую неделю (\(date.formatWith(dateFormat: "EEEEEE").lowercased()))"
            )
        )
        
        cellViewModels.append(
            TaskRepeatPeriodVariantCellViewModel(
                period: "1week[mon,tue,wed,thu,fri]",
                imageSettings: DateVariantCellViewModel.ImageSettings(name: "rectangle.stack.badge.person.crop"),
                title: "Рабочие дни"
            )
        )
        
        cellViewModels.append(
            TaskRepeatPeriodVariantCellViewModel(
                period: "1month",
                imageSettings: DateVariantCellViewModel.ImageSettings(name: "square.grid.3x3.topleft.filled"),
                title: "Каждый месяц"
            )
        )
        
        cellViewModels.append(
            TaskRepeatPeriodVariantCellViewModel(
                period: "1year",
                imageSettings: DateVariantCellViewModel.ImageSettings(name: "calendar.badge.clock"),
                title: "Каждый год"
            )
        )
        
        cellViewModels.append(
            CustomVariantCellViewModel(
                imageSettings: DateVariantCellViewModel.ImageSettings(name: "calendar"),
                title: "Настроить период"
            )
        )
        
        return cellViewModels
    }
    
    
    // MARK: child view models building
    func getCustomTaskRepeatPeriodSetterViewModel() -> CustomTaskRepeatPeriodSetterViewModel {
        return CustomTaskRepeatPeriodSetterViewModel(repeatPeriod: repeatPeriod)
    }
    
}
