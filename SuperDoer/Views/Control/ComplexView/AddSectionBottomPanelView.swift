
import UIKit

/// Вьюха с элементами для добавления нового раздела (списка) включающая в себя:
/// - textField - поле для ввода названия нового списка
/// - createButton - кнопка для добавления раздела (списка)
class AddSectionBottomPanelView: UIView {
    typealias PanelParams = (
        panelHeight: Float,
        createButtonTrailingConstant: Float,
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
                    createButtonTrailingConstant: 50,
                    plusImageColor: InterfaceColors.textBlue,
                    textFieldPlaceholderColor: InterfaceColors.textBlue,
                    textFieldPlaceholderWeight: .medium
                )
                
            case .editable :
                return (
                    panelHeight: 68,
                    createButtonTrailingConstant: -16,
                    plusImageColor: InterfaceColors.controlsGray,
                    textFieldPlaceholderColor: InterfaceColors.textGray,
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
    private lazy var textField = AddSectionTextField()
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
            UIView.animate(withDuration: 0.2) {
                self.layoutIfNeeded()
            }
        }
    }
    
    /// Констрэинт смещения кнопки "Создать раздел (список)" относительно trailing  стороны
    /// Обновление нужно производить через свойство createButtonTrailingConstant
    private var createButtonTrailingConstraint: NSLayoutConstraint?
    private var createButtonTrailingConstant: Float = State.base.params.createButtonTrailingConstant {
        didSet {
            createButtonTrailingConstraint?.constant = createButtonTrailingConstant.cgFloat
            UIView.animate(withDuration: 0.1) {
                self.layoutIfNeeded()
            }
        }
    }
    
    
    // MARK: init
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        setupViews()
        addSubviews()
        setupConstraints()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
    // MARK: layout / appearance
    private func setupViews() {
        // self
        translatesAutoresizingMaskIntoConstraints = false
        backgroundColor = InterfaceColors.white
        
        // textFeild
        textField.delegate = self
        
        // createButton
        createButton.translatesAutoresizingMaskIntoConstraints = false
        createButton.setImage(createCheckmarkImage(), for: .normal)
        createButton.backgroundColor = InterfaceColors.textBlue
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
        
        
        let createButtonTrailingConstraint = createButton.trailingAnchor.constraint(
            equalTo: self.trailingAnchor,
            constant: currentState.params.createButtonTrailingConstant.cgFloat
        )
        self.createButtonTrailingConstraint = createButtonTrailingConstraint
        NSLayoutConstraint.activate([
            createButton.heightAnchor.constraint(equalToConstant: 50),
            createButton.widthAnchor.constraint(equalToConstant: 50),
            createButton.centerYAnchor.constraint(equalTo: self.centerYAnchor),
            createButtonTrailingConstraint,
        ])
    }
    
    
    private func updateAppearaceFor(state: State) {
        if state == .base {
            layer.shadowOpacity = 0
        } else if state == .editable {
            layer.shadowColor = UIColor.black.cgColor
            layer.shadowRadius = 5
            layer.shadowOffset = CGSize(width: 0, height: 0)
            layer.shadowOpacity = 0.25
        }
        
        let params = state.params
        panelHeight = params.panelHeight
        createButtonTrailingConstant = params.createButtonTrailingConstant
        
        textField.updateAppearanceFor(state: state)
    }
    
    
    // MARK: action-handlers
    @objc func tapCreateSectionButton() {
        if let text = textField.text, text.count != 0 {
            delegate?.createSectionWith(title: text)
            textField.text = nil
        }
        
        textField.resignFirstResponder()
    }
    
    
    // MARK: methods helpers
    private func createCheckmarkImage() -> UIImage {
        let image = UIImage.init(
            systemName: "checkmark",
            withConfiguration: UIImage.SymbolConfiguration(weight: .medium)
        )?.withTintColor(
            InterfaceColors.white,
            renderingMode: .alwaysOriginal
        )
        
        guard let image = image else {
            // залогировать, а не кидать исключение
            fatalError("Image checkmark not found")
        }
        
        return image
    }
    
}

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

protocol AddSectionBottomPanelViewDelegate: AnyObject {
    func createSectionWith(title: String)
}






class AddSectionTextField: UITextField {
    let placeholderText = "Создать список"
    
    private lazy var leftImageView = UIImageView()
    
    
    override var isHighlighted: Bool {
        didSet {
//            if isHighlighted {
//                leftImageView.tintColor = InterfaceColors.textGray
//                self.setTextFieldPlaceholderColor(isEditable: true)
//            } else {
//                leftImageView.tintColor = InterfaceColors.textBlue
//                setTextFieldPlaceholderColor(isEditable: false)
//            }
        }
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        translatesAutoresizingMaskIntoConstraints = false
        
        font = UIFont.systemFont(ofSize: 17)
        textColor = InterfaceColors.blackText
        
        attributedPlaceholder = NSAttributedString(
            string: placeholderText,
            attributes: [
                .foregroundColor: InterfaceColors.textBlue,
                .font: UIFont.systemFont(ofSize: 17, weight: .medium)
            ]
        )
        
        
        // left image
        leftImageView.image = createPlusImage()
        leftImageView.image?.withTintColor(.red)
        leftImageView.frame.size = CGSize(width: 25, height: 25)
        
        leftView = UIView()
        leftView?.addSubview(leftImageView)
        leftView?.frame.size = CGSize(width: leftImageView.frame.width + 16, height: leftImageView.frame.height)
        
        leftViewMode = .always
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func updateAppearanceFor(state: AddSectionBottomPanelView.State) {
        let params = state.params
        
        leftImageView.tintColor = params.plusImageColor
        setTextFieldPlaceholderColorFor(state)
    }
    
    
    func setTextFieldPlaceholderColorFor(_ state: AddSectionBottomPanelView.State) {
        guard let attributedPlaceholder = attributedPlaceholder?.mutableCopy() as? NSMutableAttributedString else {
            return
        }
        
        let params = state.params
        attributedPlaceholder.addAttribute(
            .foregroundColor,
            value: params.textFieldPlaceholderColor,
            range: NSRange(location: 0, length: attributedPlaceholder.string.count)
        )
        
        attributedPlaceholder.addAttribute(
            .font,
            value: UIFont.systemFont(ofSize: 17, weight: params.textFieldPlaceholderWeight),
            range: NSRange(location: 0, length: attributedPlaceholder.string.count)
        )
        
        self.attributedPlaceholder = attributedPlaceholder
    }
    
    private func createPlusImage() -> UIImage {
        let image = UIImage.init(systemName: "plus")?.withRenderingMode(.alwaysTemplate)
        
        guard let image = image else {
            // залогировать, а не кидать исключение
            fatalError("Image plus not found")
        }
        
        return image
    }
    
}


@available(iOS 17, *)
#Preview {
    AddSectionBottomPanelView()
}
