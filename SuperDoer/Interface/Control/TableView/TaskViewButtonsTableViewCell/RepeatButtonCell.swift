
import UIKit


/// Кнопка-ячейка "Периодичность повторов задачи"
class RepeatButtonCell: TaskViewLabelsButtonCell {
    enum State: String {
        case empty
        case defined
    }
    
    class override var identifier: String {
        get {
            return "RepeatButtonCell"
        }
    }
    
    var state: State = .empty {
        didSet {
            guard state != oldValue else {
                return
            }
            
            configureForState(state)
        }
    }
    
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
    
    func configureForState(_ state: State) {
        switch state {
        case .empty :
            mainTextLabel.text = "Повтор"
            
            mainTextLabel.textColor = InterfaceColors.textGray
            leftImageView.tintColor = InterfaceColors.textGray
            actionButton.isHidden = true
            
        case .defined :
            // TODO: получить из модели задачи настройки + сформировать строку
            mainTextLabel.text = "Каждый месяц"
            
            mainTextLabel.textColor = InterfaceColors.textBlue
            leftImageView.tintColor = InterfaceColors.textBlue
            actionButton.isHidden = false
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
        if state == .defined {
            state = .empty
        }
    }
}
