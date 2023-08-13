

import UIKit

/// Ячейка для кнопки с лэйблами
class TaskViewLabelsButtonCell: TaskViewBaseButtonCell, TaskViewButtonCellProtocol {
    var standartHeight: Int = 58
    // TODO: сделать, чтобы высота ячейки вычислялась сама
    
    
    class override var identifier: String {
        get {
            return "WithLabelsButtonCell"
        }
    }
    
    let mainTextLabel = UILabel()
    
    
    // MARK: setup methods
    override func addSubviews() {
        super.addSubviews()
        
        contentView.addSubview(mainTextLabel)
    }
    
    override func setupViews()
    {
        super.setupViews()
        
        mainTextLabel.translatesAutoresizingMaskIntoConstraints = false
        mainTextLabel.numberOfLines = 1
        mainTextLabel.font = mainTextLabel.font.withSize(16)
    }
    
    override func setupConstraints() {
        super.setupConstraints()
        
        // mainTextLabel
        NSLayoutConstraint.activate([
            mainTextLabel.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
            mainTextLabel.leftAnchor.constraint(equalTo: leftImageView.centerXAnchor, constant: 32),
            mainTextLabel.rightAnchor.constraint(equalTo: actionButton.centerXAnchor, constant: -32),
        ])
    }
    
}
