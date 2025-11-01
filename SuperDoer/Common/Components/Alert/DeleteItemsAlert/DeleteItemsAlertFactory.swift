import UIKit

class DeleteItemsAlertFactory {

    func makeAlert<T: DeletableItemViewModelType>(
        _ item: T,
        message: String? = nil,
        onConfirm: ((T) -> Void)? = nil,
        onCancel: (() -> Void)? = nil
    ) -> UIAlertController {
        self.makeAlert([item], message: message) { _ in
            onConfirm?(item)
        } onCancel: {
            onCancel?()
        }
    }

    func makeAlert<T: DeletableItemViewModelType>(
        _ items: [T],
        message: String? = nil,
        onConfirm: (([T]) -> Void)? = nil,
        onCancel: (() -> Void)? = nil
    ) -> UIAlertController {

        let itemTypeName = getItemTypeName(for: items)
        let title = buildTitle(items: items, itemTypeName: itemTypeName)

        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)

        let deleteTitle = "Удалить \(items.count == 1 ? itemTypeName.oneVP : itemTypeName.manyVP)"
        let deleteAction = UIAlertAction(title: deleteTitle, style: .destructive) { _ in
            onConfirm?(items)
        }

        let cancelAction = UIAlertAction(title: "Отмена", style: .cancel) { _ in
            onCancel?()
        }

        alert.addAction(deleteAction)
        alert.addAction(cancelAction)

        let impactHeavy = UIImpactFeedbackGenerator(style: .heavy)
        impactHeavy.impactOccurred()

        return alert
    }

    private func getItemTypeName(
        for items: [DeletableItemViewModelType]
    ) -> DeletableItemViewModelType.ItemTypeName {
        if let item = items.first {
            return type(of: item).typeName
        } else {
            return BaseDeletableItemViewModel.typeName
        }
    }

    private func buildTitle(
        items: [DeletableItemViewModelType],
        itemTypeName: DeletableItemViewModelType.ItemTypeName
    ) -> String {
        var title: String
        if items.count == 1, let item = items.first {
            let resultItemTitle = "\"\(item.title)\" "
            title = "\(itemTypeName.oneIP.firstLetterCapitalized) \(resultItemTitle)будет удален(а) без возможности восстановления"
        } else {
            title = "Вы действительно хотите удалить выбранные \(itemTypeName.manyVP)?"
        }

        return title
    }
}
