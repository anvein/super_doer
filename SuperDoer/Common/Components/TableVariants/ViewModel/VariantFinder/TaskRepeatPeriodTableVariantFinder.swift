import Foundation

final class TaskRepeatPeriodTableVariantFinder: TableVariantSelectedFinder {
    typealias Value = String
    typealias Item = VariantCellViewModel<Value>

    func findSelectedIndex(of value: Value?, in items: [Item]) -> Int? {
        guard let value else { return nil }

        var resultIndex: Int?
        for (index, item) in items.enumerated() {
            if item.value == value {
                resultIndex = index
                break
            }
        }

        // если ни один из вариантов не определен как выбранный,
        // и у "Задачи" указан repeatPeriod, то выбран последний вариант (кастомный)
        if resultIndex == nil {
            for (index, item) in items.enumerated() {
                if item is CustomVariantCellViewModel {
                    resultIndex = index
                    break
                }
            }
        }

        return resultIndex
    }

}
