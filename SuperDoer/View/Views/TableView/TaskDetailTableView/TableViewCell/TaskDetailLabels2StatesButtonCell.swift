
import UIKit

/// Ячейка для кнопки с лэйблами и 2мя состояниями
class TaskDetailLabels2StatesButtonCell: TaskDetailLabelsButtonCell {
    var defaultMainText: String {
        return "Main text"
    }
    
    var defaultAdditionalText: String? {
        return nil
    }
    
    class override var identifier: String {
        return "TaskDetailLabelsStatesButtonCell"
    }
    
    enum State: String {
        case empty
        case defined
    }
    
    struct Value {
        var mainText: String?
        var additionalText: String?
        
        func isFilled() -> Bool {
            return mainText != nil || additionalText != nil
        }
        
        func isFullFilled() -> Bool {
            return mainText != nil && additionalText != nil
        }
    }
    
    /// Это свойство вручную не нельзя менять, надо менять value
    /// Оно меняется только в configureForState()
    private(set) var state: State = .empty {
        didSet {
            guard state != oldValue else {
                return
            }
            
            configureForState(state)
        }
    }
    
    var value: Value? {
        didSet {
            if let value, value.isFilled() {
                mainTextLabel.text = value.mainText
                additionalTextLabel.text = value.additionalText
                state = .defined
            } else {
                mainTextLabel.text = self.defaultMainText
                additionalTextLabel.text = self.defaultAdditionalText
                state = .empty
            }
        }
    }
    
    weak var delegate: Labels2StatesButtonCellDelegate?
    
    
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
    /// Нужно менять свойство value
    private func configureForState(_ state: State) {
        switch state {
        case .empty :
            actionButton.isHidden = true
            labelsStackView.spacing = 0
            
            mainTextLabel.textColor = InterfaceColors.textGray
            leftImageView.tintColor = InterfaceColors.textGray
        case .defined :
            actionButton.isHidden = false
            if let value, value.isFullFilled() {
                labelsStackView.spacing = 2
            } else {
                labelsStackView.spacing = 0
            }
            
            mainTextLabel.textColor = InterfaceColors.textBlue
            additionalTextLabel.textColor = InterfaceColors.textBlue
            leftImageView.tintColor = InterfaceColors.textBlue
        }
    }
    

    // MARK: handlers
    @objc func handleTapActionButton(actionButton: UIButton) {
        delegate?.didTapLabels2StatesCellCrossButton(cellIdentifier: Self.identifier)
    }
    
}

// MARK: delegate protocol
protocol Labels2StatesButtonCellDelegate: AnyObject {
    /// Была нажата кнопка "крестик" в ячейке
    func didTapLabels2StatesCellCrossButton(cellIdentifier: String)
}
