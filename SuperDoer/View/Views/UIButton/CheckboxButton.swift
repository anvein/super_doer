
import UIKit

/// Кнопка "Чекбокс" (Выполнение задачи)
class CheckboxButton: UIButton {
    // MARK: properties
    static let outerSize: Float = 32
    static let imageSize: Float = 26
    
    override var isHighlighted: Bool {
        didSet {
            Self.animate(withDuration: 0.15, delay: 0, options: [.beginFromCurrentState, .allowUserInteraction]) {
                self.transform = self.isHighlighted ? .init(scaleX: 0.85, y: 0.85) : .identity
            }
        }
    }
    
    var isOn: Bool = false {
        didSet {
            guard oldValue != isOn else {
                return
            }
            
            setAppearanceForState(isOn)
        }
    }
    
    var delegate: CheckboxButtonDelegate?
    
    
    // MARK: init
    init(width: Float = CheckboxButton.imageSize, height: Float = CheckboxButton.imageSize, isOnDefault: Bool = false) {
        super.init(frame: .zero)
        next
        setupButton(width: width, height: height, isOnDefault: isOnDefault)
        addWidthAndHeightConstraints(width: width, height: height)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
    // MARK: setup
    private func setupButton(width: Float, height: Float, isOnDefault: Bool = false) {
        translatesAutoresizingMaskIntoConstraints = false

        // TODO - переделать на конфигурацию
        imageEdgeInsets = UIEdgeInsets(top: 6, left: 6, bottom: 6, right: 6)
        
        layer.cornerRadius = CGFloat(width / 2)
        layer.borderWidth = 2
        setAppearanceForState(isOnDefault)
        
        layer.masksToBounds = true
        
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
    @objc private func btnTouchUpInside(sender: CheckboxButton) {
        isOn = !isOn
        delegate?.checkboxDidChangeValue(newValue: isOn)
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


protocol CheckboxButtonDelegate {
    func checkboxDidChangeValue(newValue: Bool)
}


// MARK: preview
@available(iOS 17, *)
#Preview {
    CheckboxButton()
}
