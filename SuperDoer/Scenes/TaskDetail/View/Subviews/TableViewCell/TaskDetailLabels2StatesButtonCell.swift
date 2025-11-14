import UIKit

/// Ячейка для кнопки с лэйблами и 2мя состояниями
class TaskDetailLabels2StatesButtonCell: TaskDetailLabelsButtonCell {
    var defaultMainText: String {
        return "Main text"
    }
    
    var defaultAdditionalText: String? {
        return nil
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
    
    // MARK: - Setup

    override func setupSubviews()
    {
        super.setupSubviews()
        
        configureForState(state)
    }
    
    /// Этот метод не нужно вызывать самостоятельно
    /// Нужно менять свойство value
    private func configureForState(_ state: State) {
        switch state {
        case .empty :
            actionButton.isHidden = true
            labelsStackView.spacing = 0
            
            mainTextLabel.textColor = .Text.gray
            leftImageView.tintColor = .Text.gray
        case .defined :
            actionButton.isHidden = false
            if let value, value.isFullFilled() {
                labelsStackView.spacing = 2
            } else {
                labelsStackView.spacing = 0
            }
            
            mainTextLabel.textColor = .Text.blue
            additionalTextLabel.textColor = .Text.blue
            leftImageView.tintColor = .Text.blue
        }
    }
    
}
