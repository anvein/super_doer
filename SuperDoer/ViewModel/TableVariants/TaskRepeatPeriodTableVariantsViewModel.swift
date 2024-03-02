
import Foundation

/// ViewModel для контроллера выбора предустановленного варианта периода повтора задачи
/// для поля "Период" у задачи
class TaskRepeatPeriodTableVariantsViewModel: TableVariantsViewModelType {
    
    // MARK: model
    private var task: Task {
        didSet {
            let cellViewModels = TaskRepeatPeriodTableVariantsViewModel.buildCellViewModels()
            variantCellViewModels = Box(cellViewModels)

            //refreshSelectionOfVariantCellValue(fromTask: task)
            variantCellViewModels.forceUpdate()
        }
    }
    
    // MARK: state
    var isShowReadyButton: Box<Bool> = Box(true)
    var isShowDeleteButton: Box<Bool>
    
    var variantCellViewModels: Box<[BaseVariantCellViewModel]>
    
    init(task: Task) {
        self.task = task
        
        variantCellViewModels = Box(TaskRepeatPeriodTableVariantsViewModel.buildCellViewModels())
        isShowDeleteButton = Box(false)
        
        //refreshSelectionOfVariantCellViewModel(fromTask: task)
        refreshIsShowDeleteButton(fromTask: task)
    }
    
    
    func getCountVariants() -> Int {
        return variantCellViewModels.value.count
    }
    
    func getVariantCellViewModel(forIndexPath indexPath: IndexPath) -> BaseVariantCellViewModel {
        return variantCellViewModels.value[indexPath.row]
    }
    
    
    private func refreshIsShowDeleteButton(fromTask task: Task) {
        isShowDeleteButton.value = task.repeatPeriod != nil
    }
    
    private static func buildCellViewModels() -> [BaseVariantCellViewModel] {
        var cellViewModels = [BaseVariantCellViewModel]()
        
        cellViewModels.append(
            TaskRepeatPeriodVariantCellViewModel(
                imageSettings: DateVariantCellViewModel.ImageSettings(name: "clock.arrow.circlepath"),
                title: "Каждый день",
                period: "1day"
            )
        )
        
        let date = Date()
        cellViewModels.append(
            TaskRepeatPeriodVariantCellViewModel(
                imageSettings: DateVariantCellViewModel.ImageSettings(name: "square.grid.3x1.below.line.grid.1x2.fill"),
                title: "Каждую неделю (\(date.formatWith(dateFormat: "EEEEEE").lowercased()))",
                period: "1week[wed]"
            )
        )
        
        cellViewModels.append(
            TaskRepeatPeriodVariantCellViewModel(
                imageSettings: DateVariantCellViewModel.ImageSettings(name: "rectangle.stack.badge.person.crop"),
                title: "Рабочие дни",
                period: "1week[mon,tue,wed,thu,fri]"
            )
        )
        
        cellViewModels.append(
            TaskRepeatPeriodVariantCellViewModel(
                imageSettings: DateVariantCellViewModel.ImageSettings(name: "square.grid.3x3.topleft.filled"),
                title: "Каждый месяц",
                period: "1month"
            )
        )
        
        cellViewModels.append(
            TaskRepeatPeriodVariantCellViewModel(
                imageSettings: DateVariantCellViewModel.ImageSettings(name: "calendar.badge.clock"),
                title: "Каждый год",
                period: "1year"
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
    
    
}
