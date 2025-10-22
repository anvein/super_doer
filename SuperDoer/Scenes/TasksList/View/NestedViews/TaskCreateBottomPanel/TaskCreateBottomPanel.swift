import UIKit
import RxRelay
import RxSwift
import RxCocoa

final class TaskCreateBottomPanel: UIView {

    enum Answer {
        case onConfirmCreateTask(TaskCreateData)
        case onChangedState(State)
    }

    // MARK: - Subviews

    private let textField = TextField()
    private let readyButton = UIButton()
    private let blurBgEffectView = UIVisualEffectView()

    // MARK: - State / Rx

    private let disposeBag = DisposeBag()

    private let currentStateRelay = BehaviorRelay<State>(value: .base)
    var currentStateValue: State {
        currentStateRelay.value
    }

    private let answerRelay = PublishRelay<Answer>()
    var answerSignal: Signal<Answer> {
        answerRelay.asSignal()
    }

    // MARK: - Subviews Accessors

    var textFieldPlaceholder: String? {
        get { textField.placeholder }
        set { textField.placeholder = newValue }
    }

    // MARK: - Init

    convenience init() {
        self.init(frame: .zero)

        setupHierarchy()
        setupView()
        setupBindings()
    }

    // MARK: - Lifecycle

    override func layoutSubviews() {
        super.layoutSubviews()
        readyButton.layer.cornerRadius = readyButton.bounds.width / 2
    }
}


private extension TaskCreateBottomPanel {

    // MARK: - Setup

    func setupHierarchy() {
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

    func setupView() {
        textField.delegate = self
        textField.autocorrectionType = .no

        readyButton.backgroundColor = .systemBlue
        readyButton.setImage(buildCheckmarkImage(), for: .normal)

        let blurEffect = UIBlurEffect(style: .systemUltraThinMaterialDark)
        blurBgEffectView.effect = blurEffect
        blurBgEffectView.layer.cornerRadius = 8
        blurBgEffectView.layer.masksToBounds = true
    }

    func setupBindings() {
        currentStateRelay
            .distinctUntilChanged()
            .subscribe(onNext: { [weak self] state in
                self?.updateAppearaceFor(state: state)
            })
            .disposed(by: disposeBag)

        currentStateRelay
            .distinctUntilChanged()
            .map { .onChangedState($0) }
            .bind(to: answerRelay)
            .disposed(by: disposeBag)

        readyButton.rx.tap
            .subscribe(onNext: { [weak self] in
                self?.handleTapReadyButton()
            })
            .disposed(by: disposeBag)
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

    func changeAppearance() {
        var newState: State
        switch currentStateValue {
        case .base:
            newState = .editable
        case .editable:
            newState = .base
        }

        currentStateRelay.accept(newState)
    }

    func handleTapReadyButton() {
        if let text = textField.text?.trimmingCharacters(in: .whitespaces), !text.isEmpty {
            answerRelay.accept(
                .onConfirmCreateTask(
                    TaskCreateData(title: text)
                )
            )
        }

        textField.text = nil
        textField.resignFirstResponder()
    }

    // MARK: - Helpers

    func buildCheckmarkImage() -> UIImage {
        let symbolConfig = UIImage.SymbolConfiguration(weight: .medium)
        let image = UIImage.SfSymbol.checkmark.withConfiguration(symbolConfig)
            .withTintColor(
                .Common.white,
                renderingMode: .alwaysOriginal
            )

        return image
    }

}

// MARK: - UITextFieldDelegate

extension TaskCreateBottomPanel: UITextFieldDelegate {
    func textFieldDidBeginEditing(_ textField: UITextField) {
        guard currentStateValue != .editable else { return }
        currentStateRelay.accept(.editable)
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        guard currentStateValue != .base else { return }
        currentStateRelay.accept(.base)
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        if textField === self.textField {
            handleTapReadyButton()
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
