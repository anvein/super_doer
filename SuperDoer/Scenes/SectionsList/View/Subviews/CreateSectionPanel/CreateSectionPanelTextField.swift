import UIKit

final class CreateSectionPanelTextField: UITextField {
    let placeholderText = "Создать список"

    // MARK: - Subviews

    private lazy var leftImageView = UIImageView()

    // MARK: - Init

    override init(frame: CGRect) {
        super.init(frame: frame)
        
        setupControl()
        updateAppearanceFor(state: .base)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - Update view

    func updateAppearanceFor(state: CreateSectionPanelView.State) {
        let params = state.params

        leftImageView.tintColor = params.plusImageColor
        setTextFieldPlaceholderColorFor(state)
    }
}

private extension CreateSectionPanelTextField {

    // MARK: - Setup

    func setupControl() {
        translatesAutoresizingMaskIntoConstraints = false
        font = UIFont.systemFont(ofSize: 17)
        textColor = .Text.black
        placeholder = placeholderText

        // left image
        leftImageView.image = UIImage.init(systemName: "plus")?.withTintColor(.red, renderingMode: .alwaysTemplate)
        leftImageView.frame.size = CGSize(width: 25, height: 25)

        leftView = UIView()
        leftView?.addSubview(leftImageView)
        leftView?.frame.size = CGSize(width: leftImageView.frame.width + 16, height: leftImageView.frame.height)

        leftViewMode = .always
    }

    func setTextFieldPlaceholderColorFor(_ state: CreateSectionPanelView.State) {
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

}
