import UIKit
import RxRelay
import RxCocoa
import RxSwift

final class CreateSectionPanelView: UIView {

    enum Answer {
        case onConfirmCreate(SectionCreateData)
        case onChangedState(State)
    }

    struct PanelParams {
        let panelHeight: Float
        let createButtonCenterYConstant: Float
        let plusImageColor: UIColor
        let textFieldPlaceholderColor: UIColor
        let textFieldPlaceholderWeight: UIFont.Weight
    }

    enum State {
        case base
        case editable

        var params: PanelParams {
            switch self {
            case .base:
                return .init(
                    panelHeight: 48,
                    createButtonCenterYConstant: 85,
                    plusImageColor: .Text.blue,
                    textFieldPlaceholderColor: .Text.blue,
                    textFieldPlaceholderWeight: .medium
                )

            case .editable:
                return .init(
                    panelHeight: 68,
                    createButtonCenterYConstant: 0,
                    plusImageColor: .Common.darkGrayApp,
                    textFieldPlaceholderColor: .Text.gray,
                    textFieldPlaceholderWeight: .regular
                )
            }
        }
    }

    // MARK: - State / Rx

    private let disposeBag = DisposeBag()

    private(set) var currentStateRelay: BehaviorRelay<State> = .init(value: .base)
    var currentStateValue: State {
        currentStateRelay.value
    }

    private let answerRelay = PublishRelay<Answer>()
    var answerSignal: Signal<Answer> {
        answerRelay.asSignal()
    }

    // MARK: - Subviews

    private lazy var textField = CreateSectionPanelTextField()
    private lazy var createButton = UIButton()

    // MARK: - Constraints
    /// Высота плашки
    /// т.к. констрэинты к этой плашке добавляются во вне этого класса,
    /// то чтобы высота платки менялась надо присвоить в это свойство констрэинт высоты
    /// Обновление нужно производить через свойство panelHeight
    var panelHeightConstraint: NSLayoutConstraint?
    private var panelHeight: Float = State.base.params.panelHeight {
        didSet {
            panelHeightConstraint?.constant = panelHeight.cgFloat
        }
    }

    /// Констрэинт смещения кнопки "Создать раздел (список)" относительно self.centerYAnchor
    /// Обновление нужно производить через свойство createButtonCenterYConstant
    private var createButtonCenterYConstraint: NSLayoutConstraint?
    private var createButtonCenterYConstant: Float = State.base.params.createButtonCenterYConstant {
        didSet {
            createButtonCenterYConstraint?.constant = createButtonCenterYConstant.cgFloat

            let duration = createButtonCenterYConstant < oldValue ? 0.3 : 0.2
            UIView.animate(withDuration: duration) {
                self.layoutIfNeeded()
            }
        }
    }

    // MARK: - Init

    override init(frame: CGRect) {
        super.init(frame: frame)

        setupViews()
        setupHierarchyAndConstraints()
        setupBindings()
        updateAppearaceFor(state: .base)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

}

private extension CreateSectionPanelView {
    // MARK: - Setup

    func setupViews() {
        translatesAutoresizingMaskIntoConstraints = false
        backgroundColor = .Common.white

        textField.delegate = self

        createButton.translatesAutoresizingMaskIntoConstraints = false
        createButton.setImage(createCheckmarkImage(), for: .normal)
        createButton.backgroundColor = .Text.blue
        createButton.layer.cornerRadius = 25
    }

    func setupHierarchyAndConstraints() {
        addSubviews(textField, createButton)

        NSLayoutConstraint.activate([
            textField.topAnchor.constraint(equalTo: self.topAnchor),
            textField.bottomAnchor.constraint(equalTo: self.bottomAnchor),
            textField.leadingAnchor.constraint(equalTo: self.leadingAnchor, constant: 16),
            textField.trailingAnchor.constraint(equalTo: createButton.leadingAnchor, constant: -16),
        ])

        let createButtonCenterYConstraint = createButton.centerYAnchor.constraint(equalTo: self.centerYAnchor)
        self.createButtonCenterYConstraint = createButtonCenterYConstraint

        NSLayoutConstraint.activate([
            createButton.heightAnchor.constraint(equalToConstant: 50),
            createButton.widthAnchor.constraint(equalToConstant: 50),
            createButton.trailingAnchor.constraint(equalTo: self.trailingAnchor, constant: -16),
            createButtonCenterYConstraint,
        ])
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

        createButton.rx.tap
            .subscribe(onNext: { [weak self] in
                self?.handleTapCreateButton()
            })
            .disposed(by: disposeBag)
    }

    func updateAppearaceFor(state: State) {
        let params = state.params
        panelHeight = params.panelHeight
        createButtonCenterYConstant = params.createButtonCenterYConstant

        if state == .base {
            layer.shadowOpacity = 0
        } else if state == .editable {
            layer.shadowColor = UIColor.black.cgColor
            layer.shadowRadius = 5
            layer.shadowOffset = CGSize(width: 0, height: 0)
            layer.shadowOpacity = 0.25
        }

        textField.updateAppearanceFor(state: state)
    }

    // MARK: - Actions handlers

    func handleTapCreateButton() {
        if let text = textField.text, text.count != 0 {
            answerRelay.accept(
                .onConfirmCreate(.init(title: text))
            )
        }

        textField.text = nil
        textField.resignFirstResponder()
    }

    // MARK: - Helpers

    func createCheckmarkImage() -> UIImage {
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

extension CreateSectionPanelView: UITextFieldDelegate {
    func textFieldDidBeginEditing(_ textField: UITextField) {
        currentStateRelay.accept(.editable)
    }

    func textFieldDidEndEditing(_ textField: UITextField) {
        currentStateRelay.accept(.base)
    }

    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        if self.textField === textField {
            handleTapCreateButton()
        }

        return false
    }
}

// MARK: - Preview

@available(iOS 17, *)
#Preview {
    CreateSectionPanelView()
}
