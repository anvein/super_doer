
import UIKit


/// Кнопка "Звездочка" (Добавление задачи в избранное)
class StarButton: UIButton {
    // MARK: properties
    static let outerSize: Float = 42
    static let imageSize: Float = 30
    
    var isOn: Bool = false {
        didSet {
            guard oldValue != isOn else {
                return
            }
            
            setAppearanceForState(isOn)
        }
    }
    
    weak var delegate: StarButtonDelegate?
    
    
    // MARK: init
    init(
        width: Float = StarButton.outerSize,
        height: Float = StarButton.outerSize,
        isOnDefault: Bool = false
    ) {
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
        
        imageView?.frame.size = CGSize(width: StarButton.imageSize.cgFloat, height: StarButton.imageSize.cgFloat)
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
    
    // TODO: переделать на использование tintColor
    private func setStateOn() {
        let color = UIColor(red: 102 / 255, green: 122 / 255, blue: 202 / 255, alpha: 1)
        let starOnImage = UIImage(systemName: "star.fill")?.withTintColor(color, renderingMode: .alwaysOriginal)
    
        setImage(starOnImage, for: .normal)
    }
    
    private func setStateOff() {
        let color = UIColor(red: 109 / 255, green: 109 / 255, blue: 111 / 255, alpha: 1)
        let starOffImage = UIImage(systemName: "star")?.withTintColor(color, renderingMode: .alwaysOriginal)
        
        setImage(starOffImage, for: .normal)
    }
    
    private func addWidthAndHeightConstraints(width: Float, height: Float) {
        NSLayoutConstraint.activate([
            widthAnchor.constraint(equalToConstant: width.cgFloat),
            heightAnchor.constraint(equalToConstant: height.cgFloat),
        ])
    }
    
    
    // MARK: event-handlers
    @objc private func btnTouchDown(sender: StarButton) {
        // много методов анимации
        let animation = { () -> Void in
            sender.transform = CGAffineTransform(scaleX: 1.15, y: 1.15)
        }
        
        UIView.animate(withDuration: 0.25, delay: 0, usingSpringWithDamping: 0.75, initialSpringVelocity: 1, animations: animation) { _ in
            sender.transform = CGAffineTransform(scaleX: 1, y: 1)
        }
    }
    
    @objc private func btnTouchUpInside(sender: StarButton) {
        isOn = !isOn
        delegate?.starButtonValueDidChange(newValue: isOn)
        
        // TODO: анимировать (желательно универсально)
        setAppearanceForState(isOn)
    }
    
}

protocol StarButtonDelegate: AnyObject {
    func starButtonValueDidChange(newValue: Bool)
}
