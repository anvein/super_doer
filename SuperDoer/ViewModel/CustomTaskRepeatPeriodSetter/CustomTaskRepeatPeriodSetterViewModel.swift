
import Foundation

/// ViewModel для установки кастомного периода повтора задачи
class CustomTaskRepeatPeriodSetterViewModel {
    typealias PeriodData = [String: [TaskRepeatPeriodRowViewModelType]]
    
    /// константы с индексами в которых лежат элементы (строки)
    private static let amountIndex = "amount"
    private static let typeIndex = "type"
    
    private var task: CDTask {
        didSet {
            repeatPeriod = task.repeatPeriod
            isShowDaysOfWeek = Self.computeNeedIsShowWeekDaysBy(repeatPeriod)
        }
    }
    
    weak var bindingDelegate: CustomTaskRepeatPeriodSetterViewModelBindingDelegate?

    
    // MARK: state
    var isShowReadyButton: Bool = true {
        didSet {
            bindingDelegate?.didUdpateIsShowReadyButton(newValue: isShowReadyButton)
        }
    }
    var isShowDaysOfWeek: Bool {
        didSet {
            bindingDelegate?.didUpdateIsShowDaysOfWeek(newValue: isShowDaysOfWeek)
        }
    }
    
    // TODO: переделать на другой тип
    var repeatPeriod: String? {
        didSet {
            bindingDelegate?.didUpdateRepeatPeriod(newValue: repeatPeriod)
        }
    }
    
    private var periodData: PeriodData
    
    
    // MARK: init
    init(task: CDTask) {
        self.task = task
        
        // TODO: когда в сущности будет правильный объект периода переделать заполнение self.repeatPeriod
        repeatPeriod = task.repeatPeriod
        isShowDaysOfWeek = Self.computeNeedIsShowWeekDaysBy(repeatPeriod)
        // TODO: реализовать функцию определения текущих значений
        periodData = Self.buildPeriodData()
    }
    
    
    // MARK: methods for ViewController
    func getNumberOfComponents() -> Int {
        return periodData.count
    }
    
    func getComponentKey(byIndex index: Int) -> String {
        switch index {
        case 0:
            return Self.amountIndex
        case 1:
            return Self.typeIndex
        default:
            return "undefined"
        }
    }
    
    func getNumberOfRowsInComponent(componentIndex index: Int) -> Int {
        let componentKey = getComponentKey(byIndex: index)
        return periodData[componentKey]?.count ?? 0
    }
    
    func getRowViewModel(forRow row: Int, forComponent component: Int) -> TaskRepeatPeriodRowViewModelType? {
        let componentKey = getComponentKey(byIndex: component)
        let componentRows = periodData[componentKey]
        
        guard let componentRows else { return nil }
        
        return componentRows[row]
    }
    
    
    // MARK: private view model methods
    private static func computeNeedIsShowWeekDaysBy(_ repeatPeriod: String?) -> Bool {
        guard let repeatPeriod else {
            return false
        }
        
        // TODO: если тип периода week, то выводим кнопки с днями недели
        
        return true
    }
    
    private static func buildPeriodData() -> PeriodData {
        var periodData = PeriodData()
        
        var amountData = [TaskRepeatPeriodAmountRowViewModel]()
        for index in 0...365 {
            amountData.append(
                TaskRepeatPeriodAmountRowViewModel.init(value: index + 1)
            )
        }
        periodData[Self.amountIndex] = amountData
        
        var typeData = [TaskRepeatPeriodTypeRowViewModel]()
        for value in TaskRepeatPeriodTypeRowViewModel.TypeName.allCases {
            typeData.append(
                TaskRepeatPeriodTypeRowViewModel.init(value: value)
            )
        }
        periodData[Self.typeIndex] = typeData
        
        return periodData
    }
    
}


/// Протокол с методами уведомляющими о том, что состояние полей ViewModel изменилось (для биндинга)
protocol CustomTaskRepeatPeriodSetterViewModelBindingDelegate: AnyObject {
    func didUdpateIsShowReadyButton(newValue isShow: Bool)
    
    func didUpdateIsShowDaysOfWeek(newValue isShow: Bool)
    
    func didUpdateRepeatPeriod(newValue repeatPeriod: String?)
}
