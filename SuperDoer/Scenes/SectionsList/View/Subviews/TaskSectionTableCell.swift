import UIKit

class TaskSectionTableCell: UITableViewCell {
    static let identifier: String = "TaskSectionTableViewCell"
    static let cellHeight = 48.4
    
    private let systemSectionsConfig: [TaskSystemSection.SectionType: SystemSectionViewSetting] = [
        TaskSystemSection.SectionType.myDay: SystemSectionViewSetting(
            imageName: "sun.max",
            imageColor: .SectionIcons.myDay
        ),
        TaskSystemSection.SectionType.important: SystemSectionViewSetting(
            imageName: "star",
            imageColor: .SectionIcons.important
        ),
        TaskSystemSection.SectionType.planned: SystemSectionViewSetting(
            imageName: "calendar",
            imageColor: .SectionIcons.planned
        ),
        TaskSystemSection.SectionType.all: SystemSectionViewSetting(
            imageName: "infinity",
            imageColor: .SectionIcons.allTasks,
            imageSize: 17
        ),
        TaskSystemSection.SectionType.completed: SystemSectionViewSetting(
            imageName: "checkmark.circle",
            imageColor: .SectionIcons.completed
        ),
        TaskSystemSection.SectionType.withoutSection: SystemSectionViewSetting(
            imageName: "tray",
            imageColor: .SectionIcons.withoutSection
        ),
    ]
    
    private let defaultViewConfig = SystemSectionViewSetting(
        imageName: "list.bullet",
        imageColor: .SectionIcons.default
    )
    
    // TODO: надо ли тут weak???
    // вроде цикла сильных ссылок быть не должно быть
    weak var viewModel: SectionListTableCellVMType? {
        willSet (newViewModel) {
            if let newViewModel {
                self.textLabel?.text = newViewModel.title
                self.detailTextLabel?.text = newViewModel.tasksCount
                
                configureCellImage(newViewModel)
            } else {
                self.textLabel?.text = nil
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
        textLabel?.textColor = .Text.black
        textLabel?.font = UIFont.systemFont(ofSize: 17, weight: .medium)
        textLabel?.numberOfLines = 1
        
        detailTextLabel?.textColor = .Text.gray
        detailTextLabel?.font = UIFont.systemFont(ofSize: 15, weight: .regular)
        detailTextLabel?.numberOfLines = 1
        
        backgroundColor = .Common.white
    }
    
    private func setupConstraints() {
        imageView?.centerXAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 28).isActive = true
        imageView?.centerYAnchor.constraint(equalTo: contentView.centerYAnchor).isActive = true
        
        textLabel?.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 56).isActive = true
        textLabel?.rightAnchor.constraint(equalTo: contentView.rightAnchor, constant: -56).isActive = true
        textLabel?.centerYAnchor.constraint(equalTo: contentView.centerYAnchor).isActive = true
    }

    private func configureCellImage(_ cellViewModel: SectionListTableCellVMType) {
        if let listCustomCellViewModel = cellViewModel as? SectionCustomListTableCellVM {
            configureCellImageFor(listCustomCellViewModel: listCustomCellViewModel)
            
        } else if let listSystemCellViewModel = cellViewModel as? SectionSystemListTableCellVM {
            configureCellImageFor(listSystemCellViewModel: listSystemCellViewModel)
        } 
    }
    
    private func configureCellImageFor(listCustomCellViewModel: SectionCustomListTableCellVM) {
        let symbolConfig = UIImage.SymbolConfiguration(weight: .bold)
        imageView?.image = UIImage(systemName: defaultViewConfig.imageName, withConfiguration: symbolConfig)
        imageView?.tintColor = defaultViewConfig.imageColor
    }
    
    private func configureCellImageFor(listSystemCellViewModel: SectionSystemListTableCellVM) {
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
