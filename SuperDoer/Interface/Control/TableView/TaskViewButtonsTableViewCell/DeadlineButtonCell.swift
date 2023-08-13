
import UIKit


/// Кнопка-ячейка "Срок выполнения задачи"
class DeadlineButtonCell: TaskViewLabelsButtonCell {
    enum State: String {
        /// Дата срока выполнения НЕ определена
        case undefined
        
        ///  Дата срока выполнения определена
        case defined
    }
    
    class override var identifier: String {
        get {
            return "DeadlineButtonCell"
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
            mainTextLabel.text = "Добавить дату выполнения"
            
            mainTextLabel.textColor = InterfaceColors.textGray
            leftImageView.tintColor = InterfaceColors.textGray
            actionButton.isHidden = true
            
        case .defined :
            // TODO: получить из модели задачи дату + сформировать строку с датой
            mainTextLabel.text = "Срок: Пт, 25 августа"
            
            mainTextLabel.textColor = InterfaceColors.textBlue
            leftImageView.tintColor = InterfaceColors.textBlue
            actionButton.isHidden = false
        }
    }
    
    // MARK: methods helpers
    override func createLeftButtonImage() -> UIImage? {
        let symbolConfig = UIImage.SymbolConfiguration(pointSize: 19, weight: .semibold)
        
        return UIImage(systemName: "calendar.badge.clock")?
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
