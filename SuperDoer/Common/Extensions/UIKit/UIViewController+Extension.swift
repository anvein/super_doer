import UIKit

extension UIViewController {

    func showErrorAlert(
        message: String,
        title: String? = "Ошибка",
        actionTitle: String = "ОК"
    ) {
        let alert = UIAlertController(
            title: title,
            message: message,
            preferredStyle: .alert
        )

        alert.addAction(UIAlertAction(title: actionTitle, style: .default))

        DispatchQueue.main.async {
            self.present(alert, animated: true)
        }
    }
}
