
import UIKit

extension UIView {
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
}
