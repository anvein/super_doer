

import UIKit

/// Ячейка для кнопки с лэйблами
class TaskDetailLabelsButtonCell: TaskDetailBaseCell {

    // MARK: - Subviews

    let leftImageView = UIImageView()
    let labelsStackView = UIStackView()
    let mainTextLabel = UILabel()
    let additionalTextLabel = UILabel()

    // MARK: - Setup

    override func addSubviews() {
        super.addSubviews()
    
        contentView.addSubview(leftImageView)
        contentView.addSubview(labelsStackView)
        
        labelsStackView.addArrangedSubview(mainTextLabel)
        labelsStackView.addArrangedSubview(additionalTextLabel)
    }
    
    override func setupSubviews() {
        super.setupSubviews()

        labelsStackView.axis = .vertical
        labelsStackView.alignment = .leading
        labelsStackView.distribution = .equalCentering
        labelsStackView.spacing = 0

        leftImageView.image = createLeftButtonImage()
        leftImageView.tintAdjustmentMode = .normal

        mainTextLabel.numberOfLines = 1
        mainTextLabel.font = mainTextLabel.font.withSize(16)
        
        additionalTextLabel.numberOfLines = 1
        additionalTextLabel.font = additionalTextLabel.font.withSize(14)
    }
    
    override func setupConstraints() {
        super.setupConstraints()

        leftImageView.snp.makeConstraints {
            $0.size.equalTo(23)
            $0.centerY.equalTo(contentView)
            $0.centerX.equalTo(contentView.snp.leading).offset(32)
        }

        labelsStackView.snp.makeConstraints {
            $0.centerY.equalToSuperview()
            $0.leading.equalTo(leftImageView.snp.centerX).offset(32)
            $0.right.equalTo(actionButton.snp.centerX).offset(-32)
        }
    }

    // MARK: - Helpers

    /// Override if needed
    func createLeftButtonImage() -> UIImage? {
        return nil
    }
    
}
