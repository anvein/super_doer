
import UIKit


/// Кнопка-ячейка "Срок выполнения задачи"
class TaskDataDeadlineCell: TaskDetailLabelsButtonCell {
    
    /// UUID файла, который отображается в этой ячейке
    var fileId: UUID?
    
    enum State: String {
        /// Дата срока выполнения НЕ определена
        case undefined
        
        ///  Дата срока выполнения определена
        case defined
    }
    
    class override var identifier: String {
        return "TaskDataDeadlineCell"
    }
    
    var state: State = .undefined {
        didSet {
            guard state != oldValue else {
                return
            }
            
            configureForState(state)
        }
    }
    
    weak var delegate: TaskDataDeadlineCellDelegate?
    
    
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
    
    // MARK: methods helpers
    /// Управлять контентом и состоянием кнопки надо через этот метод
    func fillFrom(_ cellValue: DeadlineCellValue) {
        if let filledDate = cellValue.date {
            let dateFormatter = DateFormatter()
            dateFormatter.locale = Locale(identifier: "ru_RU")
            dateFormatter.dateFormat = "dd MM yyyy"
            
            let stringDate = dateFormatter.string(from: filledDate)
            
            mainTextLabel.text = "Срок: \(stringDate)"
            state = .defined
        } else {
            mainTextLabel.text = "Добавить дату выполнения"
            state = .undefined
        }
    }
    
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
protocol TaskDataDeadlineCellDelegate: AnyObject {
    func tapTaskDeadlineCrossButton()
}
