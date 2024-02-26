
import UIKit

final class AddSectionPanelTextField: UITextField {
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
        
        setupControl()
        updateAppearanceFor(state: .base)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func setupControl() {
        translatesAutoresizingMaskIntoConstraints = false
        font = UIFont.systemFont(ofSize: 17)
        textColor = InterfaceColors.blackText
        placeholder = placeholderText
        
        // left image
        leftImageView.image = createPlusImage()
        leftImageView.image?.withTintColor(.red)
        leftImageView.frame.size = CGSize(width: 25, height: 25)
        
        leftView = UIView()
        leftView?.addSubview(leftImageView)
        leftView?.frame.size = CGSize(width: leftImageView.frame.width + 16, height: leftImageView.frame.height)
        
        leftViewMode = .always
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
