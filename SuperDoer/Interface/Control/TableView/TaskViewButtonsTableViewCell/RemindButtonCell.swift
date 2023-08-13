
import UIKit

// TODO: наследовать от кнопки с 2мя лэйблами

/// Кнопка-ячейка "Установить напоминания для задачи"
class RemindButtonCell: TaskViewLabelsButtonCell {
    enum State: String {
        /// Дата и время напоминания НЕ определено
        case undefined
        
        /// Дата и время напоминания определена
        case defined
    }
    
    class override var identifier: String {
        get {
            return "RemindButtonCell"
        }
    }
    
    var state: State = .undefined {
        didSet {
            guard state != oldValue else {
                return
            }
            
            configureForState(state)
        }
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
    
    func configureForState(_ state: State) {
        switch state {
        case .undefined :
            mainTextLabel.text = "Напомнить"
            
            mainTextLabel.textColor = InterfaceColors.textGray
            leftImageView.tintColor = InterfaceColors.textGray
            actionButton.isHidden = true
            
        case .defined :
            // TODO: получить из модели задачи дату + сформировать строку с датой + заполнить 2ю строку
            mainTextLabel.text = "Напомнить мне в 21:00"
            
            mainTextLabel.textColor = InterfaceColors.textBlue
            leftImageView.tintColor = InterfaceColors.textBlue
            actionButton.isHidden = false
        }
    }
    
    // MARK: methods helpers
    override func createLeftButtonImage() -> UIImage? {
        let symbolConfig = UIImage.SymbolConfiguration(pointSize: 19, weight: .semibold)
        
        return UIImage(systemName: "bell")?
            .withConfiguration(symbolConfig)
            .withRenderingMode(.alwaysTemplate)
    }
    
 
    // MARK: handlers
    @objc func handleTapActionButton(actionButton: UIButton) {
        if state == .defined {
            state = .undefined
        }
    }
}
