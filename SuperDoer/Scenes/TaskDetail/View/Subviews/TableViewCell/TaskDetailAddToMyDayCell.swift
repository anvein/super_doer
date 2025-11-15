import UIKit

class TaskDetailAddToMyDayCell: TaskDetailLabelsButtonCell {
    typealias State = Bool

    // MARK: - Settings

    override var showBottomSeparator: Bool { true }

    // MARK: - State

    var isOn: State = false {
        didSet {
            guard isOn != oldValue else { return }
            configureForState(isOn)
        }
    }

    // MARK: - Setup

    override func setupSubviews() {
        super.setupSubviews()
        labelsStackView.spacing = 0
        configureForState(isOn)
    }

    func configureForState(_ isOn: State) {
        actionButton.isHidden = !isOn

        if isOn {
            mainTextLabel.text = "Добавлено в \"Мой день\""
            mainTextLabel.textColor = .Text.blue

            leftImageView.tintColor = .Text.blue
        } else {
            mainTextLabel.text = "Добавить в \"Мой день\""
            mainTextLabel.textColor = .Text.gray

            leftImageView.tintColor = .Text.gray
        }
    }

    func fillFrom(_ cellViewModel: AddToMyDayCellViewModel) {
        self.isOn = cellViewModel.inMyDay
    }

    // MARK: - Helpers

    override func createLeftButtonImage() -> UIImage {
        let symbolConfig = UIImage.SymbolConfiguration(weight: .semibold)

        return .SfSymbol.sunMax
            .withConfiguration(symbolConfig)
            .withRenderingMode(.alwaysTemplate)
    }

}
