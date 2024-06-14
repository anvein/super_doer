
import UIKit

final class CreateTaskPanelTextField: UITextField {
    let placeholderText = "Создать задачу"
    
    private lazy var leftImageView = UIImageView()
    
//    private lazy var blurBgEffectView = UIVisualEffectView()
    
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
        
        setupControl()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupControl() {
        // self (textField)
        translatesAutoresizingMaskIntoConstraints = false
        placeholder = placeholderText
        
        font = UIFont.systemFont(ofSize: 17)
        textColor = InterfaceColors.blackText
        
        // left image (of textField)
        leftImageView.image = createPlusImage()
        leftImageView.frame.size = CGSize(width: 25, height: 25)
        leftImageView.contentMode = .scaleAspectFill
        
        leftView = UIView()
        leftView?.addSubview(leftImageView)
        leftView?.frame.size = CGSize(width: 56, height: leftImageView.frame.height)
        
        leftViewMode = .always
    }
    
    func updateAppearanceFor(state: CreateTaskBottomPanelView.State) {
        let params = state.params
        
        leftImageView.tintColor = params.textFieldImageColor
        setTextFieldPlaceholderColorFor(state)
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        if let leftView = leftView {
            leftImageView.center.x = leftView.center.x
        }
    }
    
    func setTextFieldPlaceholderColorFor(_ state: CreateTaskBottomPanelView.State) {
        guard let attributedPlaceholder = attributedPlaceholder?.mutableCopy() as? NSMutableAttributedString else {
            return
        }
        
        attributedPlaceholder.addAttribute(
            .foregroundColor,
            value: state.params.textFieldPlaceholderColor,
            range: NSRange(location: 0, length: attributedPlaceholder.string.count)
        )
        
        self.attributedPlaceholder = attributedPlaceholder
    }
    
    private func createPlusImage() -> UIImage {
        let image = UIImage.init(systemName: "plus")?
            .withRenderingMode(.alwaysTemplate)
        
        guard let image = image else {
            // залогировать, а не кидать исключение
            fatalError("Image plus not found")
        }
        
        return image
    }
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
