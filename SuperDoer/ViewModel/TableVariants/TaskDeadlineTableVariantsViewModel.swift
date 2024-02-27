
import Foundation

/// ViewModel для контроллера выбора предустановленного варианта даты
/// для поля "Дата выполнения" (дедлайн) у задачи
class TaskDeadlineTableVariantsViewModel: TableVariantsViewModelType {

    // MARK: model
    private var task: Task {
        didSet {
            let cellValues = TaskDeadlineTableVariantsViewModel.buildCellViewModels()
            variantCellViewModels = Box(cellValues)
            
            refreshSelectionOfVariantCellViewModel(fromTask: task)
            variantCellViewModels.forceUpdate()
        }
    }
    
    
    // MARK: state
    var isShowReadyButton: Box<Bool> = Box(true)
    var isShowDeleteButton: Box<Bool>
    
    var variantCellViewModels: Box<[BaseVariantCellViewModel]>
    
    
    // MARK: init
    init(task: Task) {
        self.task = task
        
        let cellViewModels = TaskDeadlineTableVariantsViewModel.buildCellViewModels()
        variantCellViewModels = Box(cellViewModels)
        isShowDeleteButton = Box(false)
        
        refreshSelectionOfVariantCellViewModel(fromTask: task)
        refreshIsShowDeleteButton(fromTask: task)
    }
    
    /// Обновляет выбранный VariantCellValue
    private func refreshSelectionOfVariantCellViewModel(fromTask task: Task) {
        let selectedIndex = calculateIndexSelectedValue(
            variants: variantCellViewModels.value,
            task: task
        )
        
        for (index, variant) in variantCellViewModels.value.enumerated() {
            variant.isSelected = index == selectedIndex
        }
    }
    
    private func calculateIndexSelectedValue(variants: [BaseVariantCellViewModel], task: Task) -> Int? {
        guard let taskDeadlineDate = task.deadlineDate else {
            return nil
        }
        
        var resultIndex: Int?
        for (index, variant) in variants.enumerated() {
            guard let variant = variant as? DateVariantCellViewModel else {
                continue
            }
            
            if variant.date.isEqualDate(date2: taskDeadlineDate) {
                resultIndex = index
                break
            }
        }
        
        // если ни один из вариантов не определен как выбранный,
        // но у "Задачи" указан deadlineDate, то выделяем последний вариант (кастомный)
        if resultIndex == nil {
            resultIndex = variants.count - 1
        }
        
        return resultIndex
    }
    
    private func refreshIsShowDeleteButton(fromTask task: Task) {
        isShowDeleteButton.value = task.deadlineDate != nil
    }
    
    // TODO: переделать метод
    // общие функции можно вынести во внешний сервис
    private static func buildCellViewModels() -> [BaseVariantCellViewModel] {
        var cellViewModels = [BaseVariantCellViewModel]()
        
        var today = Date()
        today = today.setComponents(hours: 12, minutes: 0, seconds: 0)
        
        cellViewModels.append(
            DateVariantCellViewModel(
                imageSettings: DateVariantCellViewModel.ImageSettings(name: "calendar.badge.clock"),
                title: "Сегодня",
                date: today,
                additionalText: today.formatWith(dateFormat: "EE")
            )
        )
        
        var tomorrow = Date()
        tomorrow = tomorrow.setComponents(hours: 12, minutes: 0, seconds: 0)
        tomorrow = tomorrow.add(days: 1)
        
        cellViewModels.append(
            DateVariantCellViewModel(
                imageSettings: DateVariantCellViewModel.ImageSettings(name: "arrow.right.square", size: 20),
                title: "Завтра",
                date: tomorrow,
                additionalText: tomorrow.formatWith(dateFormat: "EE")
            )
        )
        
        cellViewModels.append(
            DateVariantCellViewModel(
                imageSettings: DateVariantCellViewModel.ImageSettings(name: "calendar.day.timeline.right"),
                title: "Следующая неделя (завтра)",
                date: tomorrow,
                additionalText: today.formatWith(dateFormat: "EE")
            )
        )
        
        cellViewModels.append(
            CustomVariantCellViewModel(
                imageSettings: DateVariantCellViewModel.ImageSettings(name: "calendar"),
                title: "Выбрать дату"
            )
        )
        
        return cellViewModels
    }
    
    func getCountVariants() -> Int {
        return variantCellViewModels.value.count
    }
    
    func getVariantCellViewModel(forIndexPath indexPath: IndexPath) -> BaseVariantCellViewModel {
        return variantCellViewModels.value[indexPath.row]
    }
    
}
