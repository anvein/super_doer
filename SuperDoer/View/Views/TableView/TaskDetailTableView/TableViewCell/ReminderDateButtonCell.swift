
import UIKit

// TODO: наследовать от кнопки с 2мя лэйблами

/// Кнопка-ячейка "Установить напоминание для задачи"
class ReminderDateButtonCell: TaskDetailLabelsButtonCell {
    enum State: String {
        /// Дата и время напоминания НЕ определено
        case undefined
        
        /// Дата и время напоминания определена
        case defined
    }
    
    class override var identifier: String {
        return "RemindButtonCell"
    }
    
    var state: State = .undefined {
        didSet {
            guard state != oldValue else {
                return
            }
            
            configureForState(state)
        }
    }
    
    weak var delegate: ReminderDateButtonCellDelegate?
    
    
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
        case .undefined :
            mainTextLabel.text = "Напомнить"
            miniTextLabel.text = nil
            
            labelsStackView.spacing = 0
            
            mainTextLabel.textColor = InterfaceColors.textGray
            leftImageView.tintColor = InterfaceColors.textGray
            actionButton.isHidden = true
            
        case .defined :
            // TODO: получить из модели задачи дату + сформировать строку с датой + заполнить 2ю строку
            labelsStackView.spacing = 2
            
            mainTextLabel.textColor = InterfaceColors.textBlue
            miniTextLabel.textColor = InterfaceColors.textBlue
            leftImageView.tintColor = InterfaceColors.textBlue
            actionButton.isHidden = false
        }
    }
    
    /// Управлять контентом и состоянием кнопки надо через этот метод
    func fillFrom(_ cellValue: ReminderDateCellValue) {
        if let date = cellValue.dateTime {
            let dateFormatter = DateFormatter()
            dateFormatter.locale = Locale(identifier: "ru_RU")
            
            // TODO: Сделать формирование красивой даты (сегодня, завтра)
            dateFormatter.dateFormat = "EEEEEE, d MMMM"
            miniTextLabel.text = dateFormatter.string(from: date)
            
            dateFormatter.dateFormat = "HH:mm"
            let timeString = dateFormatter.string(from: date)
            mainTextLabel.text = "Напомнить мне в \(timeString)"
            
            state = .defined
        } else {
            mainTextLabel.text = "Напомнить"
            miniTextLabel.text = nil
            state = .undefined
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
        delegate?.didTapReminderDateCrossButton()
    }
}

// MARK: delegate protocol
protocol ReminderDateButtonCellDelegate: AnyObject {
    /// Была нажата кнопка "крестик"
    func didTapReminderDateCrossButton()
}
