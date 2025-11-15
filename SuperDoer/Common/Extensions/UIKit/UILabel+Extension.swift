import UIKit

extension UILabel {
    func setKern(_ kern: Float) {
        let attributedText = self.attributedText ?? NSAttributedString(string: self.text ?? " ")
        let mutableAttributedText = NSMutableAttributedString(attributedString: attributedText)

        mutableAttributedText.addAttributes(
            [.kern: NSNumber(value: Double(kern))],
            range: NSRange(location: 0, length: mutableAttributedText.length)
        )

        self.attributedText = mutableAttributedText
    }

    func setBaselineOffset(_ baselineOffset: Float) {
        let attributedText = self.attributedText ?? NSAttributedString(string: self.text ?? " ")
        let mutableAttributedText = NSMutableAttributedString(attributedString: attributedText)

        mutableAttributedText.addAttributes(
            [.baselineOffset: CGFloat(baselineOffset)],
            range: NSRange(location: 0, length: mutableAttributedText.length)
        )

        self.attributedText = mutableAttributedText
    }

    func setLineHeight(_ lineHeight: Float) {
        let attributedText = self.attributedText ?? NSAttributedString(string: self.text ?? " ")
        let mutableAttributedText = NSMutableAttributedString(attributedString: attributedText)

        let paragraphStyle = NSMutableParagraphStyle()
        paragraphStyle.minimumLineHeight = CGFloat(lineHeight)
        paragraphStyle.maximumLineHeight = CGFloat(lineHeight)

        mutableAttributedText.addAttributes(
            [.paragraphStyle: paragraphStyle],
            range: NSRange(location: 0, length: mutableAttributedText.length)
        )

        self.attributedText = mutableAttributedText
    }

    func setStrikedStyle(_ isStrike: Bool) {
        let attributedText = self.attributedText ?? NSAttributedString(string: self.text ?? " ")
        let mutableAttributedText = NSMutableAttributedString(attributedString: attributedText)

        let textRange = NSRange(location: 0, length: mutableAttributedText.string.count)
        if isStrike {
            // если зачеркнуть полностью, то потом не получается отменить
            mutableAttributedText.addAttribute(
                .strikethroughStyle,
                value: NSUnderlineStyle.single.rawValue,
                range: NSRange(location: 0, length: mutableAttributedText.string.count - 1)
            )
        } else {
            mutableAttributedText.removeAttribute(.strikethroughStyle, range: textRange)
        }

        self.attributedText = mutableAttributedText
    }

}
