import UIKit
import SnapKit

class BaseTextFeild: UITextField {

    // MARK: - Custom settings

    /// need configure in init()
    var textPadding: UIEdgeInsets = .init()

    /// placeholderAttributes use instead attributedPlaceholder
    var placeholderAttributes: [NSAttributedString.Key : Any] = [:] {
        didSet {
            placeholder = super.placeholder
        }
    }

    // MARK: - Overriden properties

    override var placeholder: String? {
        get { super.placeholder }
        set {
            if let newValue {
                attributedPlaceholder = .init(
                    string: newValue,
                    attributes: placeholderAttributes
                )
            } else {
                attributedPlaceholder = nil
            }
        }
    }

    // MARK: - Overriden methods

    override func textRect(forBounds bounds: CGRect) -> CGRect {
        let originalRect = super.textRect(forBounds: bounds)
        return originalRect.inset(by: textPadding)
    }

    override func placeholderRect(forBounds bounds: CGRect) -> CGRect {
        let originalRect = super.placeholderRect(forBounds: bounds)
        return originalRect.inset(by: textPadding)
    }

    override func editingRect(forBounds bounds: CGRect) -> CGRect {
        let originalRect = super.editingRect(forBounds: bounds)
        return originalRect.inset(by: textPadding)
    }

    // MARK: - Init

    convenience init(textPadding: UIEdgeInsets) {
        self.init(frame: .zero)
        self.textPadding = textPadding
    }

    // MARK: - Helpers

    func setImageToLeftView(image: UIImage, insets: UIEdgeInsets = .init())  {
        let imageView = UIImageView(image: image)
        setImageViewToLeftView(imageView: imageView, insets: insets)
    }

    func setImageViewToLeftView(imageView: UIImageView, insets: UIEdgeInsets = .init())  {
        let containerView = UIView()
        containerView.addSubview(imageView)
        imageView.snp.makeConstraints {
            $0.top.equalToSuperview().inset(insets.top)
            $0.leading.equalToSuperview().inset(insets.left)
            $0.trailing.equalToSuperview().inset(insets.right)
            $0.bottom.equalToSuperview().inset(insets.bottom)
        }
        leftView = containerView
    }
}
