import Foundation

final class TaskRepeatPeriodTableVariantFinder: TableVariantSelectedFinder {
    typealias Value = TaskRepeatPeriod
    typealias Item = VariantCellViewModel<Value>

    func findSelectedIndex(of value: Value?, in items: [Item]) -> Int? {
        guard let value else { return nil }

        var resultIndex: Int? = items.firstIndex { $0.value == value }

        // если ни один из вариантов не определен как выбранный,
        // и у "Задачи" указан repeatPeriod, то выбран последний вариант (кастомный)
        if resultIndex == nil {
            resultIndex = items.firstIndex { $0 is CustomVariantCellViewModel }
        }

        return resultIndex
    }

}
