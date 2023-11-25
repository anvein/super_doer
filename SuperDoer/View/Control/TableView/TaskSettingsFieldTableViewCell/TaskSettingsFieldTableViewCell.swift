
import UIKit

/// Ячейка с преднастроенным значением (вариантом) для таблицы с настройками (поля задачи)
class TaskSettingsFieldTableViewCell: UITableViewCell {

    enum State: String {
        /// Ячейка не выделена (значение не установлено)
        case undefined
        
        /// Ячейка выделена (значение для поля установлено / выбрано)
        case defined
    }
    
    static let identifier: String = "TaskSettingsFieldTableViewCell"
    
    var state: State = .undefined {
        didSet {
            guard state != oldValue else {
                return
            }
            
            configureForState(state)
        }
    }
    
    
    // MARK: init
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(
            style: UITableViewCell.CellStyle.value1,
            reuseIdentifier: TaskSettingsFieldTableViewCell.identifier
        )
        
        setup()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
    // MARK: setup methods
    private func setup() {
        // background
        backgroundColor = InterfaceColors.white
        selectedBackgroundView = UIView()
        selectedBackgroundView?.backgroundColor = InterfaceColors.controlsLightBlueBg
        
        // labels
        textLabel?.textColor = InterfaceColors.blackText
        textLabel?.font = UIFont.systemFont(ofSize: 16)
        
        detailTextLabel?.textColor = InterfaceColors.textGray
        detailTextLabel?.font = UIFont.systemFont(ofSize: 13)
    }
    
    /// Этот метод не нужно вызывать самостоятельно
    /// Нужно менять свойство state
    private func configureForState(_ state: State) {
        switch state {
        case .undefined :
            textLabel?.textColor = InterfaceColors.blackText
            imageView?.tintColor = InterfaceColors.blackText
            detailTextLabel?.textColor = InterfaceColors.textGray
            
        case .defined :
            textLabel?.textColor = InterfaceColors.textBlue
            imageView?.tintColor = InterfaceColors.textBlue
            detailTextLabel?.textColor = InterfaceColors.textBlue
        }
    }
    
    func createAndSetImage(with imageName: String, pointSize: Float, weight: UIImage.SymbolWeight) {
        let image = UIImage(
            systemName: imageName,
            withConfiguration: UIImage.SymbolConfiguration(
                pointSize: pointSize.cgFloat,
                weight: weight
            )
        )?.withRenderingMode(.alwaysTemplate)
        
        imageView?.image = image
        imageView?.tintColor = InterfaceColors.blackText
    }
}
