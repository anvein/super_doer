
import UIKit

final class CheckboxButton: UIButton {

    // MARK: - State

    override var isHighlighted: Bool {
        didSet {
            Self.animate(withDuration: 0.07, delay: 0, options: [.beginFromCurrentState, .allowUserInteraction]) {
                self.transform = self.isHighlighted ? .init(scaleX: 0.9, y: 0.9) : .identity
            }
        }
    }
    
    var isOn: Bool = false {
        didSet {
            guard oldValue != isOn else { return }
            setAppearanceForState(isOn)
        }
    }

    // MARK: - Init

    init() {
        super.init(frame: .zero)

        setup()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - Lifecycle

    override func layoutSubviews() {
        super.layoutSubviews()
        cornerRadius = bounds.width / 2
    }

}

private extension CheckboxButton {
    // MARK: - Setup

    func setup() {
        borderWidth = 2

        // TODO - переделать на конфигурацию
        imageEdgeInsets = UIEdgeInsets(top: 6, left: 6, bottom: 6, right: 6)
        setAppearanceForState(isOn)
    }

    // MARK: - Update view

    func setAppearanceForState(_ isOn: Bool) {
        if isOn {
            borderColor = .IsCompletedCheckbox.completedBg
            layer.backgroundColor = UIColor.IsCompletedCheckbox.completedBg.cgColor

            let image: UIImage = .Common.taskIsDoneCheckmark.withTintColor(.white, renderingMode: .alwaysOriginal)
            setImage(image, for: .normal)
        } else {
            borderColor = .Common.darkGrayApp
            layer.backgroundColor = UIColor.IsCompletedCheckbox.uncompletedBg.cgColor

            setImage(nil, for: .normal)
        }
    }
}

// MARK: - Preview

@available(iOS 17, *)
#Preview {
    CheckboxButton()
}
