
import UIKit

/// Ячейка "задачи" в таблице с задачами
class TaskListStandartTaskCell: UITableViewCell {

    lazy var isDoneButton = CheckboxButton(width: 24, height: 24)
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
     
        addSubviews()
        setupCell()
        setupConstraints()
    }
    
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        contentView.frame = contentView.frame.inset(by: UIEdgeInsets(top: 0, left: 0, bottom: 2, right: 0))
        selectedBackgroundView?.frame = contentView.frame
        backgroundView?.frame = contentView.frame
    }
    
    private func setupCell() {
        backgroundColor = nil
        
        contentView.layer.masksToBounds = true
        
        // если backgroundView не задана, то будет системная вьюха (у нее непрозрачный фон)
        backgroundView = UIView(frame: self.frame)
        
        backgroundView?.backgroundColor = InterfaceColors.white
        backgroundView?.layer.cornerRadius = 8
        backgroundView?.layer.masksToBounds = true
        
//        backgroundView?.layer.shadowColor = UIColor.systemCyan.cgColor
//        backgroundView?.layer.shadowOffset = CGSize(width: 5, height: 5)
//        backgroundView?.layer.shadowOpacity = 1
//        backgroundView?.layer.shadowRadius = 10
//        backgroundView?.clipsToBounds = false
        
        
        
//        contentView.backgroundColor = InterfaceColors.white
        
        let selectedBgView = UIView(frame: self.frame)
        
        selectedBgView.layer.cornerRadius = 8
        selectedBgView.layer.masksToBounds = true
        selectedBgView.backgroundColor = InterfaceColors.controlsLightBlueBg
        
        selectedBackgroundView = selectedBgView
        
        
        
        setupIsDoneButton()
        setupTextLabel()
    }
    
    private func addSubviews() {
        contentView.addSubview(isDoneButton)
    }
    
    private func setupTextLabel() {
        textLabel?.translatesAutoresizingMaskIntoConstraints = false
        textLabel?.font = UIFont.systemFont(ofSize: 16)
        textLabel?.textColor = InterfaceColors.blackText
    }
    
    private func setupIsDoneButton() {
        isDoneButton.translatesAutoresizingMaskIntoConstraints = false
    }
    
    private func setupConstraints() {
        // isDoneButton
        NSLayoutConstraint.activate([
            isDoneButton.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
            isDoneButton.leftAnchor.constraint(equalTo: contentView.leftAnchor, constant: 16),
        ])
        
        // textLabel
        if let safeTextLabel = textLabel {
            NSLayoutConstraint.activate([
                safeTextLabel.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 10),
                safeTextLabel.leftAnchor.constraint(equalTo: isDoneButton.rightAnchor, constant: 16),
            ])
        }
        
        
        
    }
}
