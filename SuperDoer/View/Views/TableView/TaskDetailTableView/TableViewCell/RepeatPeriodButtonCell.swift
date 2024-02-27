
import UIKit


/// Кнопка-ячейка "Периодичность повторов задачи"
class RepeatPeriodButtonCell: TaskDetailLabelsButtonCell {
    enum State: String {
        case empty
        case defined
    }
    
    class override var identifier: String {
        return "RepeatButtonCell"
    }
    
    var state: State = .empty {
        didSet {
            guard state != oldValue else {
                return
            }
            
            configureForState(state)
        }
    }
    
    weak var delegate: RepeatPeriodButtonCellDelegate?
    
    
    override var showBottomSeparator: Bool {
        return true
    }
    
    // MARK: setup methods
    override func setupViews()
    {
        super.setupViews()
        
        configureForState(state)
    }
    
    override func setupHandlers() {
        super.setupHandlers()
        
        actionButton.addTarget(self, action: #selector(handleTapActionButton(actionButton:)), for: .touchUpInside)
    }

    /// Этот метод не нужно вызывать самостоятельно
    /// Нужно менять свойство state
    private func configureForState(_ state: State) {
        switch state {
        case .empty :
            mainTextLabel.text = "Повтор"
            miniTextLabel.text = nil
            
            labelsStackView.spacing = 0
            
            mainTextLabel.textColor = InterfaceColors.textGray
            leftImageView.tintColor = InterfaceColors.textGray
            actionButton.isHidden = true
            
        case .defined :
            labelsStackView.spacing = 2
            
            mainTextLabel.textColor = InterfaceColors.textBlue
            miniTextLabel.textColor = InterfaceColors.textBlue
            leftImageView.tintColor = InterfaceColors.textBlue
            actionButton.isHidden = false
        }
    }
    
    func fillFrom(_ cellValue: RepeatPeriodCellValue) {
        if let repeatePeriod = cellValue.period {
            mainTextLabel.text = cellValue.period
            miniTextLabel.text = "вт, чт"
            state = .defined
        } else {
            mainTextLabel.text = "Период"
            miniTextLabel.text = nil
            state = .empty
        }
        
    }
    
    // MARK: methods helpers
    override func createLeftButtonImage() -> UIImage? {
        let symbolConfig = UIImage.SymbolConfiguration(pointSize: 19, weight: .medium)
        
        return UIImage(systemName: "repeat")?
            .withConfiguration(symbolConfig)
            .withRenderingMode(.alwaysTemplate)
    }
    
 
    // MARK: handlers
    @objc func handleTapActionButton(actionButton: UIButton) {
        delegate?.didTapRepeatPeriodCrossButton()
    }
}


// MARK: delegate protocol
protocol RepeatPeriodButtonCellDelegate: AnyObject {
    /// Была нажата кнопка "крестик"
    func didTapRepeatPeriodCrossButton()
}
