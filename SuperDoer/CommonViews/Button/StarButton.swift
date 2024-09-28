
import UIKit

final class StarButton: UIButton {

    // MARK: - State

    override var isHighlighted: Bool {
        didSet {
            Self.animate(withDuration: 0.1, delay: 0, options: [.beginFromCurrentState, .allowUserInteraction]) {
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
    
}

private extension StarButton {

    // MARK: - State

    private func setup() {
        // сделать отступы edgeInsets
        setAppearanceForState(isOn)
    }

    // MARK: - Update view

    private func setAppearanceForState(_ isOn: Bool) {
        let starImage: UIImage
        if isOn {
            starImage = UIImage.SfSymbol.starFill.withTintColor(.Common.blue,renderingMode: .alwaysOriginal)
        } else {
            starImage = UIImage.SfSymbol.star.withTintColor(.Common.darkGrayApp, renderingMode: .alwaysOriginal)
        }

        setImage(starImage, for: .normal)
    }

}
