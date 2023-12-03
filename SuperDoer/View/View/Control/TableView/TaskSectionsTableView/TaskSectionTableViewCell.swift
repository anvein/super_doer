
import UIKit

class TaskSectionTableViewCell: UITableViewCell {

    static let identifier: String = "TaskSectionTableViewCell"
    
    private let systemSectionsConfig: [TaskListSystem.ListType: SystemSectionViewSetting] = [
        TaskListSystem.ListType.myDay: SystemSectionViewSetting(
            imageName: "sun.max",
            imageColor: InterfaceColors.SystemSectionImage.myDay
        ),
        TaskListSystem.ListType.important: SystemSectionViewSetting(
            imageName: "star",
            imageColor: InterfaceColors.SystemSectionImage.important
        ),
        TaskListSystem.ListType.planned: SystemSectionViewSetting(
            imageName: "calendar",
            imageColor: InterfaceColors.SystemSectionImage.planned
        ),
        TaskListSystem.ListType.all: SystemSectionViewSetting(
            imageName: "infinity",
            imageColor: InterfaceColors.SystemSectionImage.all,
            imageSize: 17
        ),
        TaskListSystem.ListType.completed: SystemSectionViewSetting(
            imageName: "checkmark.circle",
            imageColor: InterfaceColors.SystemSectionImage.completed
        ),
        TaskListSystem.ListType.withoutSection: SystemSectionViewSetting(
            imageName: "tray",
            imageColor: InterfaceColors.SystemSectionImage.withoutSection
        ),
    ]
    
    private let defaultViewConfig = SystemSectionViewSetting(
        imageName: "list.bullet",
        imageColor: InterfaceColors.SystemSectionImage.defaultColor
    )
    
    weak var viewModel: TaskListTableViewCellViewModelType? {
        willSet (newViewModel) {
            self.textLabel?.text = newViewModel?.title
            
            if let safeNewViewModel = newViewModel {
                self.detailTextLabel?.text = String(safeNewViewModel.tasksCount)
                
                configureCellImage(safeNewViewModel)
            } else {
                self.detailTextLabel?.text = nil
            }
        }
    }
    
    override init(style: UITableViewCell.CellStyle = .value1, reuseIdentifier: String?) {
        super.init(style: .value1, reuseIdentifier: reuseIdentifier)
        
        setupCell()
        setupConstraints()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
    private func setupCell() {
        imageView?.translatesAutoresizingMaskIntoConstraints = false
        
        textLabel?.translatesAutoresizingMaskIntoConstraints = false
        textLabel?.textColor = InterfaceColors.blackText
        textLabel?.font = UIFont.systemFont(ofSize: 17, weight: .medium)
        textLabel?.numberOfLines = 1
        
        detailTextLabel?.textColor = InterfaceColors.textGray
        detailTextLabel?.font = UIFont.systemFont(ofSize: 15, weight: .regular)
        detailTextLabel?.numberOfLines = 1
        
        backgroundColor = InterfaceColors.white
    }
    
    private func setupConstraints() {
        imageView?.centerXAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 28).isActive = true
        imageView?.centerYAnchor.constraint(equalTo: contentView.centerYAnchor).isActive = true
        
        textLabel?.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 56).isActive = true
        textLabel?.rightAnchor.constraint(equalTo: contentView.rightAnchor, constant: -56).isActive = true
        textLabel?.centerYAnchor.constraint(equalTo: contentView.centerYAnchor).isActive = true
    }

    private func configureCellImage(_ cellViewModel: TaskListTableViewCellViewModelType) {
        if let listCustomCellViewModel = cellViewModel as? TaskListCustomTableViewCellViewModel {
            configureCellImageFor(listCustomCellViewModel: listCustomCellViewModel)
            
        } else if let listSystemCellViewModel = cellViewModel as? TaskListSystemTableViewCellViewModel {
            configureCellImageFor(listSystemCellViewModel: listSystemCellViewModel)
        }
        
    }
    
    private func configureCellImageFor(listCustomCellViewModel: TaskListCustomTableViewCellViewModel) {
        let symbolConfig = UIImage.SymbolConfiguration(weight: .bold)
        imageView?.image = UIImage(systemName: defaultViewConfig.imageName, withConfiguration: symbolConfig)
        imageView?.tintColor = defaultViewConfig.imageColor
    }
    
    private func configureCellImageFor(listSystemCellViewModel: TaskListSystemTableViewCellViewModel) {
        let viewConfig = systemSectionsConfig[listSystemCellViewModel.type] ?? defaultViewConfig
        
        let symbolConfig = UIImage.SymbolConfiguration(
            pointSize: viewConfig.imageSize.cgFloat,
            weight: .bold
        )
        imageView?.image = UIImage(systemName: viewConfig.imageName, withConfiguration: symbolConfig)
        imageView?.tintColor = viewConfig.imageColor
    }
    
}

struct SystemSectionViewSetting {
    var imageName: String
    var imageColor: UIColor
    var imageSize: Float = 18.5
}
