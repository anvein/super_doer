import UIKit
import SnapKit

final class CheckboxButton: UIButton {

    private let checkImageView = UIImageView()
    private let imageViewContainer = UIView()

    private var imageInsetsConstraint: Constraint?
    private var visibleAreaInsetsConstraint: Constraint?

    var visibleAreaInsets: CGFloat = 0 {
        didSet {
            visibleAreaInsetsConstraint?.update(inset: visibleAreaInsets)
        }
    }

    var imageInsets: CGFloat = 5.5 {
        didSet {
            imageInsetsConstraint?.update(inset: imageInsets)
        }
    }

    // MARK: - State

    override var isHighlighted: Bool {
        didSet {
            Self.animate(withDuration: 0.07, delay: 0, options: [.beginFromCurrentState, .allowUserInteraction]) {
                self.transform = self.isHighlighted ? .init(scaleX: 0.9, y: 0.9) : .identity
            }
        }
    }
    
    var isOn: Bool = false {
        didSet {
            guard oldValue != isOn else { return }
            setAppearanceForState(isOn)
        }
    }

    // MARK: - Init

    init() {
        super.init(frame: .zero)

        setup()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - Lifecycle

    override func layoutSubviews() {
        super.layoutSubviews()
        imageViewContainer.cornerRadius = imageViewContainer.bounds.width / 2
    }

}

private extension CheckboxButton {

    // MARK: - Setup

    func setup() {
        addSubview(imageViewContainer)
        imageViewContainer.addSubview(checkImageView)

        imageViewContainer.snp.makeConstraints {
            self.visibleAreaInsetsConstraint = $0.edges
                .equalToSuperview()
                .inset(visibleAreaInsets).constraint
        }

        checkImageView.snp.makeConstraints {
            self.imageInsetsConstraint = $0.edges.equalToSuperview().inset(imageInsets).constraint
        }

        imageViewContainer.borderWidth = 2
        imageViewContainer.isUserInteractionEnabled = false
        checkImageView.contentMode = .scaleAspectFill

        setAppearanceForState(isOn)
    }

    // MARK: - Update view

    func setAppearanceForState(_ isOn: Bool) {
        if isOn {
            imageViewContainer.borderColor = .IsCompletedCheckbox.completedBg
            imageViewContainer.backgroundColor = UIColor.IsCompletedCheckbox.completedBg

            let image: UIImage = .Common.taskIsDoneCheckmark.withTintColor(.white, renderingMode: .alwaysOriginal)
            checkImageView.image = image
        } else {
            imageViewContainer.borderColor = .Common.darkGrayApp
            imageViewContainer.backgroundColor = UIColor.IsCompletedCheckbox.uncompletedBg

            checkImageView.image = nil
        }
    }
}

// MARK: - Preview

@available(iOS 17, *)
#Preview {
     {
        let btn = CheckboxButton()
        btn.frame = .init(origin: .zero, size: .init(width: 40, height: 40))
        return btn
    }()
}





