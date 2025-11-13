import Foundation

final class TaskDeadlineTableVariantFinder: TableVariantSelectedFinder {
    typealias Value = Date
    typealias Item = VariantCellViewModel<Date>

    func findSelectedIndex(of value: Value?, in items: [Item]) -> Int? {
        guard let value else { return nil }

        var resultIndex: Int?
        for (index, item) in items.enumerated() {
            if let itemValue = item.value, itemValue.isEqualDate(date2: value) {
                resultIndex = index
                break
            }
        }

        // если ни один из вариантов не определен как выбранный,
        // и у "Задачи" указан deadlineDate, то выбран последний вариант (кастомный)
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
