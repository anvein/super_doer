import UIKit

extension UIStackView {
    public func addArrangedSubviews(_ views: UIView...) {
        views.forEach {
            addArrangedSubview($0)
        }
    }

    public func getArrangedSubview(with index: Int) -> UIView? {
        arrangedSubviews[safe: index]
    }

    public func removeAllArrangedSubviews() {
        let removedSubviews = arrangedSubviews

        for subview in removedSubviews {
            removeArrangedSubview(subview)
            subview.removeFromSuperview()
        }
    }

    public func removeArrangedSubviewsAfter(index: Int) {
        guard index >= 0, index < arrangedSubviews.count - 1 else { return }

        let viewsToRemove = arrangedSubviews[(index + 1)...]
        for view in viewsToRemove {
            removeArrangedSubview(view)
            view.removeFromSuperview()
        }
    }
}
