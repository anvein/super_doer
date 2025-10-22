import UIKit

/// Вьюха с элементами для добавления нового раздела (списка) включающая в себя:
/// - textField - поле для ввода названия нового списка
/// - createButton - кнопка для добавления раздела (списка)
final class AddSectionBottomPanelView: UIView {
    typealias PanelParams = (
        panelHeight: Float,
        createButtonCenterYConstant: Float,
        plusImageColor: UIColor,
        textFieldPlaceholderColor: UIColor,
        textFieldPlaceholderWeight: UIFont.Weight
    )
    
    enum State {
        case base
        case editable
        
        var params: PanelParams {
            switch self {
            case .base :
                return (
                    panelHeight: 48,
                    createButtonCenterYConstant: 85,
                    plusImageColor: .Text.blue,
                    textFieldPlaceholderColor: .Text.blue,
                    textFieldPlaceholderWeight: .medium
                )
                
            case .editable :
                return (
                    panelHeight: 68,
                    createButtonCenterYConstant: 0,
                    plusImageColor: .Common.darkGrayApp,
                    textFieldPlaceholderColor: .Text.gray,
                    textFieldPlaceholderWeight: .regular
                )
            }
        }
    }
    
    private var currentState: State = .base {
        didSet {
            if oldValue != currentState {
                updateAppearaceFor(state: currentState)
            }
        }
    }
    
    weak var delegate: AddSectionBottomPanelViewDelegate?
    
    
    // MARK: properties views
    private lazy var textField = AddSectionPanelTextField()
    private lazy var createButton = UIButton()
    
    
    // MARK: properties constraints
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
        addSubviews()
        setupConstraints()
        updateAppearaceFor(state: .base)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

}

private extension AddSectionBottomPanelView {
    // MARK: layout / appearance
    private func setupViews() {
        // self
        translatesAutoresizingMaskIntoConstraints = false
        backgroundColor = .Common.white

        // textFeild
        textField.delegate = self

        // createButton
        createButton.translatesAutoresizingMaskIntoConstraints = false
        createButton.setImage(createCheckmarkImage(), for: .normal)
        createButton.backgroundColor = .Text.blue
        createButton.layer.cornerRadius = 25

        createButton.addTarget(self, action: #selector(tapCreateSectionButton), for: .touchUpInside)
    }

    private func addSubviews() {
        addSubview(textField)
        addSubview(createButton)
    }

    private func setupConstraints() {
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
            createButton.trailingAnchor.constraint(equalTo: self.trailingAnchor,constant: -16),
            createButtonCenterYConstraint
        ])
    }

    private func updateAppearaceFor(state: State) {
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

    @objc func tapCreateSectionButton() {
        if let text = textField.text, text.count != 0 {
            delegate?.createSectionWith(title: text)
            textField.text = nil
        }

        textField.resignFirstResponder()
    }

    // MARK: methods helpers
    private func createCheckmarkImage() -> UIImage {
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

extension AddSectionBottomPanelView: UITextFieldDelegate {
    func textFieldDidBeginEditing(_ textField: UITextField) {
        currentState = .editable
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        currentState = .base
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        if self.textField === textField {
            self.tapCreateSectionButton()
        }
        
        return false
    }
}

// MARK: - Preview

@available(iOS 17, *)
#Preview {
    AddSectionBottomPanelView()
}
