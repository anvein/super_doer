import UIKit
import SnapKit

/// Кнопка-ячейка "Прикрепленный файл" (к задаче)
class TaskDetailFileCell: TaskDetailLabelsButtonCell {

    // MARK: - Settings

    override class var rowHeight: Int { 70 }
    override var leftImageViewSize: CGFloat { 36 }

    // MARK: - Data

    var fileId: UUID?

    // MARK: - Subviews

    let extensionLabel = UILabel()

    // MARK: - Subviews

    override func addSubviews() {
        super.addSubviews()

        leftImageView.addSubview(extensionLabel)
    }

    override func setupSubviews() {
        super.setupSubviews()

        leftImageView.backgroundColor = .Text.blue
        leftImageView.layer.cornerRadius = 2
        leftImageView.clipsToBounds = true

        extensionLabel.textColor = .Common.white
        extensionLabel.font = UIFont.systemFont(ofSize: 12, weight: .semibold)
        extensionLabel.textAlignment = .center
        extensionLabel.numberOfLines = 1
        extensionLabel.lineBreakMode = .byTruncatingTail

        labelsStackView.spacing = 0
        mainTextLabel.textColor = .Text.black
        additionalTextLabel.textColor = .Text.gray

//        actionButton.addTarget(self, action: #selector(actionButtonTapHandle), for: .touchUpInside)
    }

    override func setupConstraints() {
        super.setupConstraints()

        extensionLabel.snp.makeConstraints {
            $0.center.equalToSuperview()
            $0.horizontalEdges.equalToSuperview().inset(3)
        }
    }

    // MARK: - Methods helpers

    override func createLeftButtonImage() -> UIImage? {
        return nil
    }

    // MARK: - Update view

    func fillFrom(cellValue: FileCellViewModel) {
        fileId = cellValue.id

        mainTextLabel.text = cellValue.name
        extensionLabel.text = cellValue.fileExtension.uppercased()
        additionalTextLabel.text = "\(cellValue.size) КБ"
    }

//    // MARK: target-action handlers
//    @objc private func actionButtonTapHandle() {
//        let tableView = superview
//        guard let buttonsTableView = tableView else {
//            return
//        }
//
//    }

}
