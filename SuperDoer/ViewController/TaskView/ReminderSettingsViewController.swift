
import UIKit

/// Контролер установки напомининания в задаче
class ReminderSettingsViewController: UIViewController {
   
    var task: Task
    
    var variantsArray: [ReminderCellValue] = ReminderSettingsViewController.fillCellsValues()
    
    var variantsTable = UITableView()
    
    
    // MARK: init
    init(task: Task) {
        self.task = task
        
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
    // MARK: lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()

        setupControls()
        addSubviews()
        setupConstraints()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        
        fillFrom(task: task)
    }
    
    
    // MARK: setup methods
    private func setupControls() {
        view.backgroundColor = InterfaceColors.white
        modalPresentationStyle = .pageSheet
        
        title = "Напоминание"
        
        if let naviBar = navigationController?.navigationBar {
//            naviBar.translatesAutoresizingMaskIntoConstraints =
            
            naviBar.titleTextAttributes = [
                .font: UIFont.systemFont(ofSize: 18, weight: .semibold),
                .foregroundColor: InterfaceColors.blackText
            ]
        }
        
        if let sheet = sheetPresentationController {
            sheet.preferredCornerRadius = 15
            sheet.selectedDetentIdentifier = .reminderSettings
            sheet.prefersGrabberVisible = true
            sheet.prefersEdgeAttachedInCompactHeight = true
            sheet.presentedViewController.additionalSafeAreaInsets.top = 14
            sheet.widthFollowsPreferredContentSizeWhenEdgeAttached = true
        
            sheet.detents = [
                .custom(identifier: .reminderSettings, resolver: { context in
                    return 265
                }),
            ]
        }
        
        variantsTable.translatesAutoresizingMaskIntoConstraints = false
        variantsTable.dataSource = self
        variantsTable.delegate = self
        variantsTable.separatorStyle = .none
        variantsTable.backgroundColor = nil
    }
    
    private func addSubviews() {
        view.addSubview(variantsTable)
    }
    
    private func setupConstraints() {
        // variantsTable
        NSLayoutConstraint.activate([
            variantsTable.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            variantsTable.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor),
            variantsTable.rightAnchor.constraint(equalTo: view.rightAnchor),
            variantsTable.leftAnchor.constraint(equalTo: view.leftAnchor),
        ])
    }
    
    private func fillFrom(task: Task) {
        if task.reminderDateTime != nil {
            let leftBarButton = UIBarButtonItem(title: "Удалить", style: .done, target: self, action: nil)
            leftBarButton.tintColor = InterfaceColors.textRed
            navigationItem.leftBarButtonItem = leftBarButton
        }
        
        let rightBarButton = UIBarButtonItem(title: "Готово", style: .done, target: self, action: nil)
        rightBarButton.tintColor = InterfaceColors.textBlue
        navigationItem.rightBarButtonItem = rightBarButton
    }
    
    private static func fillCellsValues() -> [ReminderCellValue] {
        var cellValuesArray = [ReminderCellValue]()
        
        cellValuesArray.append(
            ReminderOptionCellValue(
                imageSettings: ReminderCellValue.ImageSettings(name: "clock.arrow.circlepath"),
                title: "Позднее сегодня",
                additionalText: "Сб 21:00"
            )
        )
        
        cellValuesArray.append(
            ReminderOptionCellValue(
                imageSettings: ReminderCellValue.ImageSettings(name: "arrow.right.square", size: 20),
                title: "Завтра",
                additionalText: "Вс 09:00"
            )
        )
        
        cellValuesArray.append(
            ReminderOptionCellValue(
                imageSettings: ReminderCellValue.ImageSettings(name: "calendar.day.timeline.right"),
                title: "Следующая неделя",
                additionalText: "Пн 09:00"
            )
        )
        
        cellValuesArray.append(
            ReminderOpenCalendarCellValue(
                imageSettings: ReminderCellValue.ImageSettings(name: "calendar", size: 18),
                title: "Выбрать дату и время"
            )
        )
        
        return cellValuesArray
    }
    
}


// MARK: table delegate & datasource
extension ReminderSettingsViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return variantsArray.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cellValue = variantsArray[indexPath.row]
        
        let cell: UITableViewCell
        switch cellValue {
        case let variantCellValue as ReminderOptionCellValue:
            cell = UITableViewCell(style: .value1, reuseIdentifier: "ReminderOptionCellValue")
            cell.backgroundColor = InterfaceColors.white
            
            cell.textLabel?.text = variantCellValue.title
            cell.textLabel?.textColor = InterfaceColors.blackText
            cell.textLabel?.font = UIFont.systemFont(ofSize: 16)
//            cell.textLabel?.
            
            cell.detailTextLabel?.text = variantCellValue.additionalText
            cell.detailTextLabel?.textColor = InterfaceColors.textGray
            cell.detailTextLabel?.font = UIFont.systemFont(ofSize: 13)
            
            
            let image = UIImage(
                systemName: cellValue.imageSettings.name,
                withConfiguration: UIImage.SymbolConfiguration(
                    pointSize: cellValue.imageSettings.size.cgFloat,
                    weight: cellValue.imageSettings.weight
                )
            )?.withRenderingMode(.alwaysTemplate)
            
            cell.imageView?.image = image
            cell.imageView?.tintColor = InterfaceColors.blackText
            
        default:
            cell = UITableViewCell(style: .value1, reuseIdentifier: "ReminderOpenCalendarCellValue")
            cell.backgroundColor = InterfaceColors.white
            
            cell.textLabel?.text = cellValue.title
            cell.textLabel?.textColor = InterfaceColors.blackText
            cell.textLabel?.font = UIFont.systemFont(ofSize: 16)
            cell.accessoryType = .disclosureIndicator
            
            let image = UIImage(
                systemName: cellValue.imageSettings.name,
                withConfiguration: UIImage.SymbolConfiguration(
                    pointSize: cellValue.imageSettings.size.cgFloat,
                    weight: cellValue.imageSettings.weight
                )
            )?.withRenderingMode(.alwaysTemplate)
            
            cell.imageView?.image = image
            cell.imageView?.tintColor = InterfaceColors.blackText
        }
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 50
    }
    
    
}


// MARK: detent identifier
typealias SheetDetentIdentifier = UISheetPresentationController.Detent.Identifier

extension UISheetPresentationController.Detent.Identifier {
    static let reminderSettings: SheetDetentIdentifier = SheetDetentIdentifier("reminderSettings")
}



// MARK: cell values objects
class ReminderCellValue {
    struct ImageSettings {
        var name: String
        var size: Int = 18
        var weight: UIImage.SymbolWeight = .medium
    }
    
    var imageSettings: ImageSettings
    var title: String
    
    init(imageSettings: ImageSettings, title: String) {
        self.imageSettings = imageSettings
        self.title = title
    }
}

class ReminderOptionCellValue: ReminderCellValue {
    var additionalText: String?
    
    init(imageSettings: ImageSettings, title: String, additionalText: String? = nil) {
        super.init(imageSettings: imageSettings, title: title)
        
        self.additionalText = additionalText
    }
}

class ReminderOpenCalendarCellValue: ReminderCellValue  {

}


