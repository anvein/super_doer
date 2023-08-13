
import UIKit

/// Кнопка-ячейка "Добавить задачу в Мой день"
class AddToMyDayButtonCell: TaskViewLabelsButtonCell {
    typealias State = Bool
    
    class override var identifier: String {
        get {
            return "AddToMyDayButtonCell"
        }
    }
    
    /// true - active / on, false - inactive / off
    var isOn: State = false {
        didSet {
            guard isOn != oldValue else {
                return
            }
            
            configureForState(isOn)
        }
    }
    
    override var showTopSeparator: Bool {
        return true
    }
    
    override var showBottomSeparator: Bool {
        return true
    }
    
    
    // MARK: setup methods
    override func setupViews()
    {
        super.setupViews()
        
        configureForState(isOn)
    }
    
    override func setupHandlers() {
        super.setupHandlers()
        
        actionButton.addTarget(self, action: #selector(handleTapActionButton(actionButton:)), for: .touchUpInside)
    }
    
    func configureForState(_ isOn: State) {
        actionButton.isHidden = !isOn
        
        if isOn {
            mainTextLabel.text = "Добавлено в \"Мой день\""
            mainTextLabel.textColor = InterfaceColors.textBlue
            
            leftImageView.tintColor = InterfaceColors.textBlue
        } else {
            mainTextLabel.text = "Добавить в \"Мой день\""
            mainTextLabel.textColor = InterfaceColors.textGray
            
            leftImageView.tintColor = InterfaceColors.textGray
        }
    }
    
    
    // MARK: methods helpers
    override func createLeftButtonImage() -> UIImage? {
        let symbolConfig = UIImage.SymbolConfiguration(pointSize: 19, weight: .semibold)
        
        return UIImage(systemName: "sun.max")?
            .withConfiguration(symbolConfig)
            .withRenderingMode(.alwaysTemplate)
    }
    
    
    // MARK: handlers
    @objc func handleTapActionButton(actionButton: UIButton) {
        isOn = !isOn
    }
    
}
