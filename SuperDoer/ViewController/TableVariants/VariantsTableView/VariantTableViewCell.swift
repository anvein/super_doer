
import UIKit

/// Ячейка с преднастроенным значением (вариантом)  для таблицы с вариантами
class VariantTableViewCell: UITableViewCell {

    enum State: String {
        /// Ячейка не выделена (значение не установлено)
        case undefined
        
        /// Ячейка выделена (значение для поля установлено / выбрано)
        case defined
    }
    
    static let identifier: String = "VariantTableViewCell"
    
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
            reuseIdentifier: VariantTableViewCell.identifier
        )
        
        setup()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
    // MARK: setup methods
    private func setup() {
        // background
        backgroundColor = .Common.white
        selectedBackgroundView = UIView()
        selectedBackgroundView?.backgroundColor = .Common.lightBlueBg
        
        // labels
        textLabel?.textColor = .Text.black
        textLabel?.font = UIFont.systemFont(ofSize: 16)
        
        detailTextLabel?.textColor = .Text.gray
        detailTextLabel?.font = UIFont.systemFont(ofSize: 13)
    }
    
    /// Этот метод не нужно вызывать самостоятельно
    /// Нужно менять свойство state
    private func configureForState(_ state: State) {
        switch state {
        case .undefined :
            textLabel?.textColor = .Text.black
            imageView?.tintColor = .Text.black
            detailTextLabel?.textColor = .Text.gray
            
        case .defined :
            textLabel?.textColor = .Text.blue
            imageView?.tintColor = .Text.blue
            detailTextLabel?.textColor = .Text.blue
        }
    }
    
    
    private func fillBase(cellViewModel: BaseVariantCellViewModel) {
        textLabel?.text = cellViewModel.title
        imageView?.image = createImage(
            with: cellViewModel.imageSettings.name,
            pointSize: Float(cellViewModel.imageSettings.size),
            weight: cellViewModel.imageSettings.weight
        )
        imageView?.tintColor = .Text.black
        
        state = cellViewModel.isSelected ? .defined : .undefined
    }
    
    func fillFrom(cellViewModel: DateVariantCellViewModel) {
        fillBase(cellViewModel: cellViewModel)
        
        detailTextLabel?.text = cellViewModel.additionalText
    }
    
    func fillFrom(cellViewModel: TaskRepeatPeriodVariantCellViewModel) {
        fillBase(cellViewModel: cellViewModel)
    }
    
    func fillFrom(cellViewModel: CustomVariantCellViewModel) {
        fillBase(cellViewModel: cellViewModel)
        accessoryType = .disclosureIndicator
    }
    
    func createImage(with imageName: String, pointSize: Float, weight: UIImage.SymbolWeight) -> UIImage? {
        return UIImage(
            systemName: imageName,
            withConfiguration: UIImage.SymbolConfiguration(
                pointSize: pointSize.cgFloat,
                weight: weight
            )
        )?.withRenderingMode(.alwaysTemplate)
    }
}
