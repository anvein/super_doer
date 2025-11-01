import UIKit

final class NotificationsDisabledAlertFactory {

    typealias OnSelectAnswerCallback = (NotificationsDisabledAlertAnswer) -> Void

    func makeAlert(
        title: String? = nil,
        message: String? = nil,
        onSelectAnswer: OnSelectAnswerCallback? = nil
    ) -> UIAlertController {
        let alert = UIAlertController(
            title: title ?? "Уведомления выключены",
            message: message ?? """
                                Нам нужно ваше разрешение для напоминаний.
                                Включите уведомления в разделе "Параметры" > "Уведомления"
                                """,
            preferredStyle: .actionSheet
        )

        alert.addAction(createEnableNotifiesAction(onSelectAnswer))
        alert.addAction(createNotNowAction(onSelectAnswer))
        alert.addAction(createCancelAction(onSelectAnswer))

        return alert
    }

    // MARK: - Private actions

    private func createEnableNotifiesAction(
        _ onSelectAnswer: OnSelectAnswerCallback?
    ) -> UIAlertAction {
        UIAlertAction(title: "Включить уведомления", style: .default) { _ in
            onSelectAnswer?(.enableNotifications)
        }
    }

    private func createNotNowAction(_ onSelectAnswer: OnSelectAnswerCallback?) -> UIAlertAction {
        UIAlertAction(title: "Не сейчас", style: .destructive) { _ in
            onSelectAnswer?(.notNow)
        }
    }

    private func createCancelAction(_ onSelectAnswer: OnSelectAnswerCallback?) -> UIAlertAction {
        UIAlertAction(title: "Отмена", style: .cancel) { _ in
            onSelectAnswer?(.cancel)
        }
    }
}
