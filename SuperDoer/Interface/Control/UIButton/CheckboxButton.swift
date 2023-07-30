
import UIKit

/// Кнопка "Чекбокс" (Выполнение задачи)
class CheckboxButton: UIButton {
    // MARK: properties
    static let outerSize: Float = 32
    static let imageSize: Float = 26
    
    var isOn: Bool = false {
        didSet {
            guard oldValue != isOn else {
                return
            }
            
            setAppearanceForState(isOn)
        }
    }
    
    
    // MARK: init
    init(width: Float = CheckboxButton.imageSize, height: Float = CheckboxButton.imageSize, isOnDefault: Bool = false) {
        super.init(frame: .zero)
        
        setupButton(isOnDefault: isOnDefault)
        addWidthAndHeightConstraints(width: width, height: height)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
    // MARK: setup
    private func setupButton(isOnDefault: Bool = false) {
        translatesAutoresizingMaskIntoConstraints = false

        // TODO - переделать на конфигурацию
        imageEdgeInsets = UIEdgeInsets(top: 6, left: 6, bottom: 6, right: 6)
        
        layer.cornerRadius = CGFloat(CheckboxButton.imageSize / 2)
        layer.borderWidth = 2
        setAppearanceForState(isOnDefault)
        
        layer.masksToBounds = true
        
        addTarget(self, action: #selector(btnTouchDown(sender:)), for: .touchDown)
        addTarget(self, action: #selector(btnTouchUpInside(sender:)), for: .touchUpInside)
    }
    
    private func setAppearanceForState(_ isOn: Bool) {
        if isOn {
            setStateOn()
        } else {
            setStateOff()
        }
    }
    
    private func setStateOn() {
        layer.borderColor = InterfaceColors.completedCheckboxBg.cgColor
        layer.backgroundColor = InterfaceColors.completedCheckboxBg.cgColor
        
        setImage(createCheckmarkImage(), for: .normal)
    }
    
    private func setStateOff() {
        layer.borderColor = InterfaceColors.controlsGray.cgColor
        layer.backgroundColor = InterfaceColors.unCompletedCheckboxBg.cgColor
        
        setImage(nil, for: .normal)
    }
    
    private func addWidthAndHeightConstraints(width: Float, height: Float) {
        NSLayoutConstraint.activate([
            widthAnchor.constraint(equalToConstant: width.cgFloat),
            heightAnchor.constraint(equalToConstant: height.cgFloat),
        ])
    }
    
    
    // MARK: event-handlers
    @objc private func btnTouchDown(sender: CheckboxButton) {
        // много методов анимации
        let animation = { () -> Void in
            sender.transform = CGAffineTransform(scaleX: 0.9, y: 0.9)
        }
        
        UIView.animate(withDuration: 0.25, delay: 0, animations: animation) { _ in
            sender.transform = CGAffineTransform(scaleX: 1, y: 1)
        }
    }
    
    @objc private func btnTouchUpInside(sender: CheckboxButton) {
        isOn = !isOn
        
        // TODO: анимировать (желательно универсально)
        setAppearanceForState(isOn)
    }
    
    // MARK: methods helpers
    private func createCheckmarkImage() -> UIImage {
        let image = UIImage.init(named: "checkmark3")?.withTintColor(
            UIColor(red: 1, green: 1, blue: 1, alpha: 1),
            renderingMode: .alwaysOriginal
        )
        
        guard let safeImage = image else {
            // точно надо кидать ошибку?
            // ведь при тестировании это можно пропустить, а оно потом на прод вылетит
            fatalError("Image checkmark3 not found")
        }
        
        return safeImage
    }
    
}
