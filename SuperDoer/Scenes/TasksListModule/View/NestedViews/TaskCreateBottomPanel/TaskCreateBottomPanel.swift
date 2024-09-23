
import UIKit
import SnapKit

final class TaskCreateBottomPanel: UIView {

    // MARK: - Services

    weak var delegate: TaskCreateBottomPanelDelegate?

    // MARK: - Subviews Accessors

    var textFieldPlaceholder: String? {
        get { textField.placeholder }
        set { textField.placeholder = newValue }
    }

    // MARK: - State

    var currentState: State = .base {
        didSet {
            if oldValue != currentState {
                updateAppearaceFor(state: currentState)
                delegate?.taskCreateBottomPanelDidChangedState(newState: currentState)
            }
        }
    }

    // MARK: - Subviews

    private lazy var textField: TextField = {
        $0.delegate = self
        $0.autocorrectionType = .no
        return $0
    }(TextField())

    private lazy var readyButton: UIButton = {
        $0.backgroundColor = .systemBlue
        $0.setImage(buildCheckmarkImage(), for: .normal)
        $0.addTarget(self, action: #selector(didTapReadyButton), for: .touchUpInside)
        return $0
    }(UIButton())

    private lazy var blurBgEffectView: UIVisualEffectView = {
        let blurEffect = UIBlurEffect(style: .systemUltraThinMaterialDark)
        $0.effect = blurEffect
        $0.layer.cornerRadius = 8
        $0.layer.masksToBounds = true
        return $0
    }(UIVisualEffectView())

    // MARK: - Init

    convenience init() {
        self.init(frame: .zero)

        setupLayout()
        updateAppearaceFor(state: currentState)
    }

    // MARK: - Lifecycle

    override func layoutSubviews() {
        super.layoutSubviews()
        readyButton.layer.cornerRadius = readyButton.bounds.width / 2
    }
}


private extension TaskCreateBottomPanel {

    // MARK: - Setup

    func setupLayout() {
        addSubviews(blurBgEffectView, textField, readyButton)

        blurBgEffectView.snp.makeConstraints {
            $0.edges.equalToSuperview()
        }

        textField.snp.makeConstraints {
            $0.top.leading.bottom.equalToSuperview().inset(8)
        }

        readyButton.snp.makeConstraints {
            $0.size.equalTo(46)
            $0.leading.equalTo(textField.snp.trailing).offset(8)
            $0.trailing.equalToSuperview().inset(8)
            $0.centerY.equalToSuperview()
        }
    }

    func updateAppearaceFor(state: State) {
        blurBgEffectView.isHidden = state.textFieldBlurBgIsHidden
        layer.backgroundColor = CGColor(red: 1, green: 1, blue: 1, alpha: state.panelBgAlpha)

        UIView.transition(
            with: readyButton,
            duration: 0.3,
            options: [.transitionCrossDissolve]
        ) { [readyButton] in
            readyButton.isHidden = state.readyButtonIsHidden
        }

        if state == .base {
            layer.shadowOpacity = 0
            roundCorners([.topLeft, .topRight, .bottomLeft, .bottomRight], radius: 8)
        } else if state == .editable {
            layer.shadowColor = UIColor.black.cgColor
            layer.shadowRadius = 10
            layer.shadowOffset = CGSize(width: 5, height: 5)
            layer.shadowOpacity = 0.75
            roundCorners([.topLeft, .topRight], radius: 8)
        }

        textField.updateAppearanceFor(state: state)
    }

    // MARK: - Actions handlers

    @objc func changeAppearance() {
        var cstate: State
        switch currentState {
        case .base:
            cstate = .editable
        case .editable:
            cstate = .base
        }

        currentState = cstate
    }

    // MARK: - Actions handlers

    @objc func didTapReadyButton() {
        if let text = textField.text, text.count != 0 {
            delegate?.taskCreateBottomPanelDidTapCreateButton(
                title: text,
                inMyDay: false,
                reminderDateTime: nil,
                deadlineAt: nil,
                description: nil
            )
            textField.text = nil
        }

        textField.resignFirstResponder()
    }


    // MARK: - Helpers

    private func buildCheckmarkImage() -> UIImage? {
        let image = UIImage.init(
            systemName: "checkmark",
            withConfiguration: UIImage.SymbolConfiguration(weight: .medium)
        )?.withTintColor(
            .white,
            renderingMode: .alwaysOriginal
        )

        return image
    }

}

// MARK: - UITextFieldDelegate

extension TaskCreateBottomPanel: UITextFieldDelegate {
    func textFieldDidBeginEditing(_ textField: UITextField) {
        guard currentState != .editable else { return }
        currentState = .editable
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        guard currentState != .base else { return }
        currentState = .base

    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        if textField === self.textField {
            didTapReadyButton()
        }
        
        return false
    }
}

// MARK: - CreateTaskBottomPanel.State

extension TaskCreateBottomPanel {
    enum State {
        case base
        case editable

        var createButtonCenterYConstant: Float {
            switch self {
            case .base: return 55
            case .editable: return 0
            }
        }

        var panelBgAlpha: CGFloat {
            switch self {
            case .base: return 0
            case .editable: return 1
            }
        }

        var textFieldBlurBgIsHidden: Bool {
            switch self {
            case .base: return false
            case .editable: return true
            }
        }

        var readyButtonIsHidden: Bool {
            switch self {
            case .base: return true
            case .editable: return false
            }
        }

        var panelSidesPadding: Float {
            switch self {
            case .base: return 8
            case .editable: return 0
            }
        }

        var panelHeight: Float {
            switch self {
            case .base: return 60
            case .editable: return 68
            }
        }

    }
}
