import UIKit

extension UIView {

    static func ifAvailableiOS26<Value>(trueValue: Value, elseValue: Value) -> Value {
        if #available(iOS 26, *) {
            return trueValue
        } else {
            return elseValue
        }
    }

    // MARK: - Layer properties

    var cornerRadius: CGFloat {
        get { layer.cornerRadius }
        set {
            layer.cornerRadius = newValue
            layer.masksToBounds = newValue > 0
        }
    }

    var borderColor: UIColor {
        get { UIColor(cgColor: layer.borderColor ?? UIColor.clear.cgColor) }
        set { layer.borderColor = newValue.cgColor }
    }

    var borderWidth: CGFloat {
        get { layer.borderWidth }
        set { layer.borderWidth = newValue }
    }

    // MARK: - Helpers

    func addSubviews(_ views: UIView...) {
        views.forEach {
            addSubview($0)
        }
    }

    func roundCorners(_ corners: UIRectCorner, radius: CGFloat) {
        let cornerMask = convertCornersToMask(corners)
        layer.cornerRadius = radius
        layer.maskedCorners = cornerMask
    }

    private func convertCornersToMask(_ corners: UIRectCorner) -> CACornerMask {
        var cornerMask = CACornerMask()

        if corners.contains(.allCorners) { cornerMask.insert([.layerMinXMinYCorner, .layerMinXMaxYCorner, .layerMaxXMinYCorner, .layerMaxXMaxYCorner]) }
        if corners.contains(.topLeft) { cornerMask.insert(.layerMinXMinYCorner) }
        if corners.contains(.topRight) { cornerMask.insert(.layerMaxXMinYCorner) }
        if corners.contains(.bottomLeft) { cornerMask.insert(.layerMinXMaxYCorner) }
        if corners.contains(.bottomRight) { cornerMask.insert(.layerMaxXMaxYCorner) }

        return cornerMask
    }

    func ifAvailableiOS26<Value>(trueValue: Value, elseValue: Value) -> Value {
        UIView.ifAvailableiOS26(trueValue: trueValue, elseValue: elseValue)
    }
}

// MARK: - HasDisposeBag

extension UIView: HasDisposeBag { }
