
import UIKit

/// Вьюха с элементами для создания новой задачи включающая в себя:
/// - textField - поле для ввода названия задачи (title)
/// - readyCreateButton - кнопка для подтверждения создания задачи
final class CreateTaskBottomPanelView: UIView {
    typealias PanelParams = (
        panelHeight: Float,
        panelCornerRadius: Float,
        panelBgAlpha: Float,
        panelSidesConstraintConstant: Float,
        panelTopConstraintConstant: Float,
        createButtonCenterYConstant: Float,
        textFieldImageColor: UIColor,
        textFieldPlaceholderColor: UIColor,
        textFieldBlurBgIsHidden: Bool
    )
    
    enum State {
        case base
        case editable
        
        var params: PanelParams {
            switch self {
            case .base :
                return (
                    panelHeight: 60,
                    panelCornerRadius: 8,
                    panelBgAlpha: 0,
                    panelSidesConstraintConstant: 8,
                    panelTopConstraintConstant: 8,
                    createButtonCenterYConstant: 55,
                    textFieldImageColor: InterfaceColors.white,
                    textFieldPlaceholderColor: InterfaceColors.white,
                    textFieldBlurBgIsHidden: false
                )
                
            case .editable :
                return (
                    panelHeight: 68,
                    panelCornerRadius: 0,
                    panelBgAlpha: 1,
                    panelSidesConstraintConstant: 0,
                    panelTopConstraintConstant: 0,
                    createButtonCenterYConstant: 0,
                    textFieldImageColor: InterfaceColors.controlsGray,
                    textFieldPlaceholderColor: InterfaceColors.textGray,
                    textFieldBlurBgIsHidden: true
                )
            }
        }
    }
    
    /// Свойство указывающее была ли панель запущена хоть раз
    /// Используется для того, чтобы не применять анимацию при первом размещении панели на экране
    var isInitialized: Bool = false
    
    override class var requiresConstraintBasedLayout: Bool {
        get {
            return true
        }
    }
    
    private var currentState: State = .base {
        didSet {
            if oldValue != currentState {
                updateAppearaceFor(state: currentState)
            }
        }
    }
    
    weak var delegate: CreateTaskBottomPanelViewDelegate?
    
    
    // MARK: properties views
    lazy var textField = CreateTaskPanelTextField()
    private lazy var readyCreateButton = UIButton()
    private lazy var blurBgEffectView = UIVisualEffectView()
    
    // MARK: properties constraints
    /// Высота панели
    /// т.к. констрэинты к этой панели создаются вне этого класса,
    /// то чтобы высота платки менялась надо присвоить в это свойство констрэинт высоты
    /// Обновление нужно производить через свойство panelHeight
    var panelHeightConstraint: NSLayoutConstraint?
    private var panelHeight: Float = State.base.params.panelHeight {
        didSet {
            panelHeightConstraint?.constant = panelHeight.cgFloat
        }
    }
    
    /// Отступы панели по бокам
    /// т.к. констрэинты к этой панели создаются вне этого класса,
    /// то чтобы боковые отступы панели менялиль надо присвоить в эти свойство констрэинт leadingAnchor и trailingAnchor
    /// Обновление нужно производить через свойство panelSidesConstraintConstant
    var panelLeadingAnchorConstraint: NSLayoutConstraint?
    var panelTrailingAnchorConstraint: NSLayoutConstraint?
    private var panelSidesConstraintConstant: Float = State.base.params.panelSidesConstraintConstant {
        didSet {
            panelLeadingAnchorConstraint?.constant =  panelSidesConstraintConstant.cgFloat
            panelTrailingAnchorConstraint?.constant =  -panelSidesConstraintConstant.cgFloat
        }
    }
    
    /// Отступ сверху от панели до таблицы
    var panelTopAnchorConstraint: NSLayoutConstraint?
    private var panelTopConstraintConstant: Float = State.base.params.panelTopConstraintConstant {
        didSet {
            panelTopAnchorConstraint?.constant = panelTopConstraintConstant.cgFloat
        }
    }
    
    /// Констрэинт смещения кнопки "Создать раздел (список)" относительно self.centerYAnchor
    /// Обновление нужно производить через свойство createButtonCenterYConstant
    private var createButtonCenterYConstraint: NSLayoutConstraint?
    private var createButtonCenterYConstant: Float = State.base.params.createButtonCenterYConstant {
        didSet {
            createButtonCenterYConstraint?.constant = createButtonCenterYConstant.cgFloat
            
            let duration = createButtonCenterYConstant < oldValue ? 0.3 : 0.1
            UIView.animate(withDuration: duration) {
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
        updateAppearaceFor(state: .base)
        
        isInitialized = true
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
    // MARK: layout / appearance
    private func setupViews() {
        // self
        translatesAutoresizingMaskIntoConstraints = false
        layer.masksToBounds = true
        
        // textFeild
        textField.delegate = self
        
        // createButton
        readyCreateButton.translatesAutoresizingMaskIntoConstraints = false
        readyCreateButton.backgroundColor = InterfaceColors.textBlue
        readyCreateButton.setImage(createCheckmarkImage(), for: .normal)
        readyCreateButton.layer.cornerRadius = 25
        
        readyCreateButton.addTarget(self, action: #selector(tapReadyCreateTaskButton), for: .touchUpInside)
        
        // blurBgEffectView
        let blurEffect = UIBlurEffect(style: .systemUltraThinMaterialDark)
        blurBgEffectView.effect = blurEffect
        blurBgEffectView.translatesAutoresizingMaskIntoConstraints = false
    }
    
    private func addSubviews() {
        addSubview(blurBgEffectView)
        addSubview(textField)
        addSubview(readyCreateButton)
    }
    
    private func setupConstraints() {
        
        NSLayoutConstraint.activate([
            textField.topAnchor.constraint(equalTo: self.topAnchor, constant: 8),
            textField.bottomAnchor.constraint(equalTo: self.bottomAnchor, constant: -8),
            textField.leadingAnchor.constraint(equalTo: self.leadingAnchor, constant: 8),
            textField.trailingAnchor.constraint(equalTo: readyCreateButton.leadingAnchor, constant: -8),
        ])
        
        let createButtonCenterYConstraint = readyCreateButton.centerYAnchor.constraint(equalTo: self.centerYAnchor)
        self.createButtonCenterYConstraint = createButtonCenterYConstraint
        NSLayoutConstraint.activate([
            readyCreateButton.heightAnchor.constraint(equalToConstant: 50),
            readyCreateButton.widthAnchor.constraint(equalToConstant: 50),
            readyCreateButton.trailingAnchor.constraint(equalTo: self.trailingAnchor,constant: -8),
            createButtonCenterYConstraint,
        ])
        
        NSLayoutConstraint.activate([
            blurBgEffectView.topAnchor.constraint(equalTo: self.topAnchor),
            blurBgEffectView.bottomAnchor.constraint(equalTo: self.bottomAnchor),
            blurBgEffectView.leadingAnchor.constraint(equalTo: self.leadingAnchor),
            blurBgEffectView.trailingAnchor.constraint(equalTo: self.trailingAnchor),
        ])
    }
    
    
    private func updateAppearaceFor(state: State) {
        let params = state.params
        
        layer.backgroundColor = CGColor(red: 1, green: 1, blue: 1, alpha: params.panelBgAlpha.cgFloat)
        layer.cornerRadius = params.panelCornerRadius.cgFloat
        blurBgEffectView.isHidden = params.textFieldBlurBgIsHidden
        panelHeight = params.panelHeight
        panelSidesConstraintConstant = params.panelSidesConstraintConstant
        panelTopConstraintConstant = params.panelTopConstraintConstant
        
        if isInitialized {
            UIView.animate(withDuration: 0.25) {
                self.layoutIfNeeded()
            }
        } else {
            layoutIfNeeded()
        }
        
        createButtonCenterYConstant = params.createButtonCenterYConstant
        
        if state == .base {
            layer.shadowOpacity = 0
            layer.mask = nil
            
            layer.borderWidth = 0
        } else if state == .editable {
            layer.shadowColor = UIColor.black.cgColor
            layer.shadowRadius = 10 // 5
            layer.shadowOffset = CGSize(width: 0, height: 0)
            layer.shadowOpacity = 1 // 0.25
            
            let maskShapeLayer = createPanelCornerRadiusMask()
            layer.mask = maskShapeLayer
            
            // TODO: переделать на тень
            layer.borderWidth = 1
            layer.borderColor = InterfaceColors.lightGray.cgColor
        }
        
        textField.updateAppearanceFor(state: state)
    }
    
    private func createPanelCornerRadiusMask() -> CAShapeLayer {
        // TODO: кешировать бы это
        let maskShapeLayer = CAShapeLayer()
        let path = UIBezierPath(
            roundedRect: self.bounds,
            byRoundingCorners: UIRectCorner([.topLeft, .topRight]),
            cornerRadii: CGSize(width: 8, height: 8)
        )
        maskShapeLayer.path = path.cgPath
        
        return maskShapeLayer
    }
    
    // MARK: action-handlers
    @objc func tapReadyCreateTaskButton() {
        if let text = textField.text, text.count != 0 {
            delegate?.createTaskWith(
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

extension CreateTaskBottomPanelView: UITextFieldDelegate {
    func textFieldDidBeginEditing(_ textField: UITextField) {
        currentState = .editable
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        currentState = .base
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        
        if textField === self.textField {
            self.tapReadyCreateTaskButton()
        }
        
        return false
    }
}

protocol CreateTaskBottomPanelViewDelegate: AnyObject {
    func createTaskWith(
        title: String,
        inMyDay: Bool,
        reminderDateTime: Date?,
        deadlineAt: Date?,
        description: String?
    )
}


@available(iOS 17, *)
#Preview {
    let imageView = UIImageView(frame: UIScreen.main.bounds)
    imageView.image = UIImage(named: "bgList")
    imageView.contentMode = .center
    
    let panel = CreateTaskPanelTextField()
    panel.translatesAutoresizingMaskIntoConstraints = true
    panel.frame = CGRect(
        origin: CGPoint(x: 0, y: 750),
        size: CGSize(width: UIScreen.main.bounds.width, height: 70)
    )
    
    imageView.addSubview(panel)

    return imageView
}
