
import UIKit


// TODO: может сделать управление через делегаты?

// Кнопка "Добавить в "Мой день""
class AddToMyDayComponent: UIView {
    typealias State = Bool
    
    static let standartHeight = 58
    
    let mainButton = UIButton()
    let crossButton = UIButton()
    
    var isOn: State
    
    init(defaultValue: State = false) {
        isOn = defaultValue
        
        super.init(frame: .zero)
        
        setupLayout()
        addSubviews()
        setupConstraints()
        setupHandlers()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func setupHandlers() {
        mainButton.addTarget(self, action: #selector(mainButtonTouchDown), for: .touchDown)
        mainButton.addTarget(self, action: #selector(mainButtonTouchUpInside), for: .touchUpInside)
        crossButton.addTarget(self, action: #selector(crossButtonTouchUpInside), for: .touchUpInside)
    }
    
    func setupLayout() {
        translatesAutoresizingMaskIntoConstraints = false
        backgroundColor = InterfaceColors.white
        
        setupMainButtonLayout()
        setupCrossButtonLayout()
    }
    
    func setupMainButtonLayout() {
        mainButton.translatesAutoresizingMaskIntoConstraints = false
        
        mainButton.contentHorizontalAlignment = .left
        mainButton.titleLabel?.font = mainButton.titleLabel?.font.withSize(16)
        // TODO: иконка обрезается! ПОЧЕМУ? ❓
        mainButton.imageEdgeInsets = UIEdgeInsets(top: 0, left: 18, bottom: 0, right: 0)
        mainButton.titleEdgeInsets = UIEdgeInsets(top: 0, left: 40, bottom: 0, right: 0)
        
        setMainButtonAppearanceForState(isOn)
    }
    
    func setMainButtonAppearanceForState(_ isOn: State) {
        mainButton.setImage(createSunImage(isOn), for: .normal)
        
        if isOn {
            mainButton.setTitle("Добавлено в \"Мой день\"", for: .normal)
            mainButton.setTitleColor(InterfaceColors.textBlue, for: .normal)
        } else {
            mainButton.setTitle("Добавить в \"Мой день\"", for: .normal)
            mainButton.setTitleColor(InterfaceColors.textGray, for: .normal)
        }
    }
    
    func setupCrossButtonLayout() {
        crossButton.translatesAutoresizingMaskIntoConstraints = false
        
        crossButton.setImage(createCrossImage(), for: .normal)
        
        setCrossButtonAppearanceForState(isOn)
    }
    
    func setCrossButtonAppearanceForState(_ isOn: State) {
        if isOn {
            crossButton.isHidden = false
        } else {
            crossButton.isHidden = true
        }
    }
    
    // MARK: add subviews and constraints
    func addSubviews() {
        addSubview(mainButton)
        addSubview(crossButton)
    }
    
    func setupConstraints() {
        // mainButton
        NSLayoutConstraint.activate([
            mainButton.heightAnchor.constraint(equalTo: heightAnchor),
            mainButton.widthAnchor.constraint(equalTo: widthAnchor)
        ])
        
        // crossButton
        NSLayoutConstraint.activate([
            crossButton.rightAnchor.constraint(equalTo: rightAnchor),
            crossButton.heightAnchor.constraint(equalTo: heightAnchor),
            crossButton.widthAnchor.constraint(equalToConstant: AddToMyDayComponent.standartHeight.cgFloat)
        ])
    }
    
    // MARK: methods helpers
    private func createSunImage(_ isOn: State) -> UIImage? {
        let symbolConfig = UIImage.SymbolConfiguration(pointSize: 19, weight: .semibold)
        
        return UIImage(systemName: "sun.max")?
            .withConfiguration(symbolConfig)
            .withTintColor(
                isOn ? InterfaceColors.textBlue : InterfaceColors.textGray,
                renderingMode: .alwaysOriginal
            )
    }
    
    private func createCrossImage() -> UIImage? {
        let symbolConfig = UIImage.SymbolConfiguration(pointSize: 12, weight: .regular)
        
        return UIImage(systemName: "xmark")?
            .withConfiguration(symbolConfig)
            .withTintColor(InterfaceColors.textGray,renderingMode: .alwaysOriginal)
    }
    
    // MARK: handlers
    @objc func mainButtonTouchDown() {
        backgroundColor = InterfaceColors.controlsLightBlueBg
    }
    
    @objc func mainButtonTouchUpInside(mainButton: UIButton) {
        isOn = !isOn
        
        setMainButtonAppearanceForState(isOn)
        setCrossButtonAppearanceForState(isOn)
        
        backgroundColor = InterfaceColors.white
    }
    
    @objc func crossButtonTouchUpInside() {
        isOn = false
        
        setMainButtonAppearanceForState(false)
        setCrossButtonAppearanceForState(false)
        
        backgroundColor = InterfaceColors.white
    }
}
