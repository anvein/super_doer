
import Foundation

/// ViewModel для контроллера выбора предустановленного варианта
/// поля "Дата выполнения" (дедлайн) у задачи
class TaskSettingsDeadlineTableVariantsViewModel: VariantsViewModelType {
    
    // TODO: переделать на DI
    var taskEm = TaskEntityManager()
     
    
    // MARK: model
    private var task: Task {
        didSet {
            let cellValues = TaskSettingsDeadlineTableVariantsViewModel.buildCellsValues()
            variantsCellValuesArray = Box(cellValues)
            
            refreshSelectionOfVariantCellValue(fromTask: task)
            variantsCellValuesArray.forceUpdate()
        }
    }
    
    
    // MARK: state
    var variantsCellValuesArray: Box<[BaseVariantCellValue]>
    
    
    // MARK: init
    init(task: Task) {
        self.task = task
        
        let cellValues = TaskSettingsDeadlineTableVariantsViewModel.buildCellsValues()
        self.variantsCellValuesArray = Box(cellValues)
        refreshSelectionOfVariantCellValue(fromTask: task)
    }
    
    /// Обновляет выбранный VariantCellValue
    private func refreshSelectionOfVariantCellValue(fromTask task: Task) {
        let selectedIndex = calculateIndexSelectedValue(
            variants: variantsCellValuesArray.value,
            task: task
        )
        
        for (index, variant) in variantsCellValuesArray.value.enumerated() {
            variant.isSelected = index == selectedIndex
        }
    }
    
    private func calculateIndexSelectedValue(variants: [BaseVariantCellValue], task: Task) -> Int? {
        guard let taskDeadlineDate = task.deadlineDate else {
            return nil
        }
        
        var resultIndex: Int?
        for (index, variant) in variants.enumerated() {
            guard let variant = variant as? DeadlineVariantCellValue else {
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
    
    
    // TODO: переделать метод
    // общие функции можно вынести во внешний сервис
    private static func buildCellsValues() -> [BaseVariantCellValue] {
        var cellValuesArray = [BaseVariantCellValue]()
        
        var today = Date()
        today = today.setComponents(hours: 12, minutes: 0, seconds: 0)
        
        cellValuesArray.append(
            DeadlineVariantCellValue(
                imageSettings: DeadlineVariantCellValue.ImageSettings(name: "calendar.badge.clock"),
                title: "Сегодня",
                date: today,
                additionalText: today.formatWith(dateFormat: "EE")
            )
        )
        
        var tomorrow = Date()
        tomorrow = tomorrow.setComponents(hours: 12, minutes: 0, seconds: 0)
        tomorrow = tomorrow.add(days: 1)
        
        cellValuesArray.append(
            DeadlineVariantCellValue(
                imageSettings: DeadlineVariantCellValue.ImageSettings(name: "arrow.right.square", size: 20),
                title: "Завтра",
                date: tomorrow,
                additionalText: tomorrow.formatWith(dateFormat: "EE")
            )
        )
        
        cellValuesArray.append(
            DeadlineVariantCellValue(
                imageSettings: DeadlineVariantCellValue.ImageSettings(name: "calendar.day.timeline.right"),
                title: "Следующая неделя (завтра)",
                date: tomorrow,
                additionalText: today.formatWith(dateFormat: "EE")
            )
        )
        
        cellValuesArray.append(
            DealineCustomVariantCellValue(
                imageSettings: DeadlineVariantCellValue.ImageSettings(name: "calendar"),
                title: "Выбрать дату"
            )
        )
        
        return cellValuesArray
    }
    
    func getCountVariants() -> Int {
        return variantsCellValuesArray.value.count
    }
    
    func getVariantCellValue(forIndexPath indexPath: IndexPath) -> BaseVariantCellValue {
        return variantsCellValuesArray.value[indexPath.row]
    }
    
}
