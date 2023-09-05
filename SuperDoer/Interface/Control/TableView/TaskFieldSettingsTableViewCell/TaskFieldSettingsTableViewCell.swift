
import UIKit

/// Ячейка с преднастроенным значением (вариантом) для таблицы с настройками (поля задачи)
class TaskFieldSettingsTableViewCell: UITableViewCell {

    static let identifier: String = "TaskFieldSettingsTableViewCell"
    
    
    // MARK: init
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        var style = UITableViewCell.CellStyle.value1
        var reuseIdentifier = TaskFieldSettingsTableViewCell.identifier
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
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
