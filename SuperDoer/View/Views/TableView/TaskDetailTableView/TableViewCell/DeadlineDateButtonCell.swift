
import UIKit


/// Кнопка-ячейка "Срок выполнения задачи"
class DeadlineDateButtonCell: TaskDetailLabelsButtonCell {
    
    enum State: String {
        /// Дата дедлайна НЕ определена
        case undefined
        
        ///  Дата дедлайна определена
        case defined
    }
    
    class override var identifier: String {
        return "DeadlineDateButtonCell"
    }
    
    var state: State = .undefined {
        didSet {
            guard state != oldValue else {
                return
            }
            
            configureForState(state)
        }
    }
    
    weak var delegate: DeadlineDateButtonCellDelegate?
    
    
    // MARK: setup methods
    override func setupViews()
    {
        super.setupViews()
        
        labelsStackView.spacing = 0
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
        case .undefined :
            mainTextLabel.textColor = InterfaceColors.textGray
            leftImageView.tintColor = InterfaceColors.textGray
            actionButton.isHidden = true
            
        case .defined :
            mainTextLabel.textColor = InterfaceColors.textBlue
            leftImageView.tintColor = InterfaceColors.textBlue
            actionButton.isHidden = false
        }
    }
    
    /// Управлять контентом и состоянием кнопки надо через этот метод
    func fillFrom(_ cellValue: DeadlineDateCellValue) {
        if let filledDate = cellValue.date {
            let dateFormatter = DateFormatter()
            dateFormatter.locale = Locale(identifier: "ru_RU")
            // TODO: Сделать формирование красивой даты (сегодня, завтра + не выводить текущий год)
            dateFormatter.dateFormat = "EEEEEE, d MMMM y"
            
            let stringDate = dateFormatter.string(from: filledDate)
            
            mainTextLabel.text = "Срок: \(stringDate)"
            state = .defined
        } else {
            mainTextLabel.text = "Добавить дату выполнения"
            state = .undefined
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
        delegate?.tapTaskDeadlineCrossButton()
    }
}


// MARK: delegate protocol
protocol DeadlineDateButtonCellDelegate: AnyObject {
    /// Была нажата кнопка "крестик"
    func tapTaskDeadlineCrossButton()
}
