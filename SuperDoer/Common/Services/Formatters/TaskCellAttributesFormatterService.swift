
import Foundation
import UIKit

final class TaskCellAttributesFormatterService {

    // MARK: - Services

    private let dateFormatter: DateFormatterService
    private let dateComparator: DateComparatorService

    // MARK: - Init

    init(
        dateFormatter: DateFormatterService = .init(),
        dateComparator: DateComparatorService = .init()
    ) {
        self.dateFormatter = dateFormatter
        self.dateComparator = dateComparator
    }

    // MARK: -

    func formatTaskAttributesForCellInList(from task: TasksListItem) -> NSAttributedString? {
        let sectionTitle = formatAsGrayTextOptional(task.sectionTitle)
        let inMyDayText = task.isInMyDay ? formatAsGrayText("Мой день", iconImage: .SfSymbol.sunMax) : nil
        let dealineDateFormatted = formatDeadlineAt(date: task.deadlineDate)
        let descriptionAttr = task.description != nil ? formatAsGrayText("Заметка", iconImage: .SfSymbol.document) : nil

        let separator = formatAsGrayText(" • ")

        let attrStrings: [NSAttributedString] = [
            inMyDayText,
            sectionTitle,
            dealineDateFormatted,
            descriptionAttr,
        ].compactMap { $0 }

        return concatAttributedStrings(attrStrings, separator: separator)
    }
}

private extension TaskCellAttributesFormatterService {

    func formatDeadlineAt(date: Date?) -> NSAttributedString? {
        guard let date else { return nil}

        var dealineDateFormatted = dateFormatter.formatDealineAtInTaskList(date: date)

        let textColor: UIColor
        if dateComparator.isDateOfYesterdayOrPreviously(date) {
            textColor = .Text.red
        } else if Calendar.current.isDateInToday(date) {
            textColor = .Text.blue
        } else {
            textColor = .Text.gray
        }

        let resultAttrString = NSMutableAttributedString()
        let symbolAttrString = formatSymbolImageForAttributedString(
            .SfSymbol.calendar,
            color: textColor,
            fontSize: 10.5
        )
        if let symbolAttrString {
            dealineDateFormatted = " \(dealineDateFormatted)"
            resultAttrString.append(symbolAttrString)
        }

        let attrText = NSAttributedString(
            string: dealineDateFormatted,
            attributes: [
                .foregroundColor: textColor.cgColor,
                .font: UIFont.systemFont(ofSize: 14),
            ]
        )
        resultAttrString.append(attrText)

        return resultAttrString
    }

    func formatAsGrayTextOptional(_ text: String?) -> NSAttributedString? {
        guard let text else { return nil }
        return formatAsGrayText(text)
    }

    func formatAsGrayText(_ text: String, iconImage: UIImage? = nil) -> NSAttributedString {
        var text = text
        let resultAttrString = NSMutableAttributedString()

        if let iconImage {
            let symbolAttrString = formatSymbolImageForAttributedString(iconImage, color: .Text.gray, fontSize: 10.5)
            if let symbolAttrString {
                text = " \(text)"
                resultAttrString.append(symbolAttrString)
            }
        }

        let textAttrString = NSAttributedString(
            string: text,
            attributes: [
                .foregroundColor: UIColor.Text.gray,
                .font: UIFont.systemFont(ofSize: 14),
            ])
        resultAttrString.append(textAttrString)

        return resultAttrString
    }

    func concatAttributedStrings(_ strings: [NSAttributedString], separator: NSAttributedString) -> NSAttributedString {
        let resultAttrString = NSMutableAttributedString()
        for (index, string) in strings.enumerated() {
            resultAttrString.append(string)
            if index < strings.count - 1 {
                resultAttrString.append(separator)
            }
        }

        return resultAttrString
    }

    private func formatSymbolImageForAttributedString(
        _ iconImage: UIImage,
        color: UIColor,
        fontSize: CGFloat
    ) -> NSAttributedString? {
        let symbolCongig = UIImage.SymbolConfiguration(pointSize: fontSize, weight: .semibold)
        let symbolImage = iconImage.withConfiguration(symbolCongig)
            .withRenderingMode(.alwaysTemplate)

        let attachment = NSTextAttachment()
        let symbolSize = UIFont.systemFont(ofSize: fontSize).lineHeight
        attachment.image = symbolImage
        attachment.bounds = CGRect(x: 0, y: -(symbolSize * 0.1), width: symbolSize, height: symbolSize)

        let attachmentString = NSAttributedString(attachment: attachment)
        let attributedString = NSMutableAttributedString(attributedString: attachmentString)

        let fullRange = NSRange(location: 0, length: attributedString.length)
        attributedString.addAttribute(.foregroundColor, value: color, range: fullRange)

        return attributedString
    }

}
