
import UIKit


/// Кнопка-ячейка "Добавить файл в задачу"
class AddFileButtonCell: TaskDetailLabelsButtonCell {
    
    class override var identifier: String {
        return "AddFileButtonCell"
    }
    
    override var showBottomSeparator: Bool {
        return true
    }
    
    // MARK: setup methods
    override func setupViews()
    {
        super.setupViews()
        
        actionButton.isHidden = true
        mainTextLabel.text = "Добавить файл"
        
        labelsStackView.spacing = 0
        
        mainTextLabel.textColor = InterfaceColors.textGray
        leftImageView.tintColor = InterfaceColors.textGray
    }
    
    // MARK: methods helpers
    override func createLeftButtonImage() -> UIImage? {
        let symbolConfig = UIImage.SymbolConfiguration(pointSize: 18, weight: .semibold)
        
        return UIImage(systemName: "paperclip")?
            .withConfiguration(symbolConfig)
            .withRenderingMode(.alwaysTemplate)
    }
    
}
