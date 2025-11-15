import UIKit

/// Кнопка-ячейка "Добавить файл в задачу"
class TaskDetailAddFileCell: TaskDetailLabelsButtonCell {

    override var showBottomSeparator: Bool {
        return true
    }

    // MARK: setup methods
    override func setupSubviews() {
        super.setupSubviews()

        actionButton.isHidden = true
        mainTextLabel.text = "Добавить файл"

        labelsStackView.spacing = 0

        mainTextLabel.textColor = .Text.gray
        leftImageView.tintColor = .Text.gray
    }

    // MARK: methods helpers
    override func createLeftButtonImage() -> UIImage? {
        let symbolConfig = UIImage.SymbolConfiguration(pointSize: 18, weight: .semibold)

        return UIImage(systemName: "paperclip")?
            .withConfiguration(symbolConfig)
            .withRenderingMode(.alwaysTemplate)
    }

}
