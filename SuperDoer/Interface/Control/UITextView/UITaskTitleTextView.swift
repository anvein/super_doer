
import UIKit

/// Контрол для реализации поля "Название задачи" на странице "Просмотра / Редактирования задачи"
class UITaskTitleTextView: UITextView {

    // MARK: init
    init() {
        super.init(frame: .zero, textContainer: nil)
        
        translatesAutoresizingMaskIntoConstraints = false
        
        isScrollEnabled = false
        returnKeyType = .done
        
        backgroundColor = InterfaceColors.white
        textColor = InterfaceColors.blackText
        font = UIFont.systemFont(ofSize: 22, weight: .medium)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}
