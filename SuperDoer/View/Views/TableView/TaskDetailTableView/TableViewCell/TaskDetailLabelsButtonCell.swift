

import UIKit

/// Ячейка для кнопки с лэйблами
class TaskDetailLabelsButtonCell: TaskDetailBaseButtonCell {
    
    class override var identifier: String {
        return "TaskDetailWithLabelsButtonCell"
    }
    
    let leftImageView = UIImageView()
    
    let labelsStackView = UIStackView()
    let mainTextLabel = UILabel()
    let additionalTextLabel = UILabel()
    
    
    // MARK: setup methods
    override func addSubviews() {
        super.addSubviews()
    
        contentView.addSubview(leftImageView)
        contentView.addSubview(labelsStackView)
        
        labelsStackView.addArrangedSubview(mainTextLabel)
        labelsStackView.addArrangedSubview(additionalTextLabel)
    }
    
    override func setupViews()
    {
        super.setupViews()
        
        leftImageView.translatesAutoresizingMaskIntoConstraints = false
        leftImageView.image = createLeftButtonImage()
        
        labelsStackView.translatesAutoresizingMaskIntoConstraints = false
        labelsStackView.axis = .vertical
        labelsStackView.alignment = .leading
        labelsStackView.distribution = .equalCentering
        labelsStackView.spacing = 0
        
        mainTextLabel.numberOfLines = 1
        mainTextLabel.font = mainTextLabel.font.withSize(16)
        
        additionalTextLabel.numberOfLines = 1
        additionalTextLabel.font = additionalTextLabel.font.withSize(14)
    }
    
    override func setupConstraints() {
        super.setupConstraints()
        
        // leftImageView
        NSLayoutConstraint.activate([
            leftImageView.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
            leftImageView.centerXAnchor.constraint(equalTo: contentView.leftAnchor, constant: 32)
        ])
        
        // labelsStackView
        NSLayoutConstraint.activate([
            labelsStackView.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
            labelsStackView.leftAnchor.constraint(equalTo: leftImageView.centerXAnchor, constant: 32),
            labelsStackView.rightAnchor.constraint(equalTo: actionButton.centerXAnchor, constant: -32),
        ])
    }
    
    // MARK: methods helpers
    func createLeftButtonImage() -> UIImage? {
        return nil
    }
    
}
