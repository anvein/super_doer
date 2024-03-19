
import UIKit

/// Кнопка-ячейка "Прикрепленный файл" (к задаче)
class FileButtonCell: TaskDetailLabelsButtonCell {
    
    override class var identifier: String {
        return "FileButtonCell"
    }
    
    override class var rowHeight: Int {
        return 70
    }
    
    /// id файла, который размещен в этой ячейке
    var fileId: UUID?
    
    
    // MARK: views
    let extensionLabel = UILabel()

    
    // MARK: setup methods
    override func addSubviews() {
        super.addSubviews()
        
        leftImageView.addSubview(extensionLabel)
    }
    
    override func setupViews()
    {
        super.setupViews()
        
        extensionLabel.translatesAutoresizingMaskIntoConstraints = false
        
        leftImageView.backgroundColor = InterfaceColors.textBlue
        leftImageView.layer.cornerRadius = 2
        leftImageView.clipsToBounds = true
        
        extensionLabel.textColor = InterfaceColors.white
        extensionLabel.font = UIFont.systemFont(ofSize: 12, weight: .semibold)
        extensionLabel.textAlignment = .center
        extensionLabel.numberOfLines = 1
        extensionLabel.lineBreakMode = .byTruncatingTail
        
        labelsStackView.spacing = 0
        mainTextLabel.textColor = InterfaceColors.blackText
        additionalTextLabel.textColor = InterfaceColors.textGray
        
//        actionButton.addTarget(self, action: #selector(actionButtonTapHandle), for: .touchUpInside)
    }
    
    override func setupConstraints() {
        super.setupConstraints()
        
        // leftImageView
        NSLayoutConstraint.activate([
            leftImageView.widthAnchor.constraint(equalToConstant: 36),
            leftImageView.heightAnchor.constraint(equalToConstant: 36),
        ])
        
        // extensionLabel
        NSLayoutConstraint.activate([
            extensionLabel.centerYAnchor.constraint(equalTo: leftImageView.centerYAnchor),
            extensionLabel.centerXAnchor.constraint(equalTo: leftImageView.centerXAnchor),
            extensionLabel.widthAnchor.constraint(equalToConstant: 30),
        ])
    }
    
    
    // MARK: methods helpers
    override func createLeftButtonImage() -> UIImage? {
        return nil
    }
    
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
