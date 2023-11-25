
import UIKit
import Foundation

/// Контролер установки Срока по задаче (выбор вариантов из списка)
class DeadlineVariantsViewController: UIViewController {
   
    var taskEm = TaskEntityManager()
    
    var task: Task
    
    var variantsCellValuesArray: [BaseDealineVariantCellValue] = DeadlineVariantsViewController.fillCellsValues()
    var variantsTableView = TaskSettingsFieldTableView()
    
    weak var delegate: DeadlineSettingsViewControllerDelegate?
    
    
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
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        
        delegate?.didDisappearDeadlineSettingsViewController(isSuccess: true)
    }
    
    
    // MARK: setup methods
    private func setupControls() {
        setupController()
        setupNavigationBar()
        setupVariantsTable()
    }
    
    private func setupController() {
        view.backgroundColor = InterfaceColors.white
        modalPresentationStyle = .pageSheet
        
        title = "Срок"
        
        if let sheet = sheetPresentationController {
            sheet.preferredCornerRadius = 15
            sheet.selectedDetentIdentifier = .taskDeadlineSettings
            sheet.prefersGrabberVisible = true
            sheet.prefersEdgeAttachedInCompactHeight = true
            sheet.presentedViewController.additionalSafeAreaInsets.top = 14
            sheet.widthFollowsPreferredContentSizeWhenEdgeAttached = true
        
            sheet.detents = [
                .custom(identifier: .taskDeadlineSettings, resolver: { context in
                    return 280
                }),
            ]
        }
    }
    
    private func setupNavigationBar() {
        if let naviBar = navigationController?.navigationBar {
            naviBar.standardAppearance.backgroundColor = InterfaceColors.white
            naviBar.titleTextAttributes = [
                .font: UIFont.systemFont(ofSize: 18, weight: .semibold),
                .foregroundColor: InterfaceColors.blackText
            ]
        }
    }
    
    private func setupVariantsTable() {
        variantsTableView.dataSource = self
        variantsTableView.delegate = self
    }
    
    private func addSubviews() {
        view.addSubview(variantsTableView)
    }
    
    private func setupConstraints() {
        // variantsTable
        NSLayoutConstraint.activate([
            variantsTableView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            variantsTableView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor),
            variantsTableView.rightAnchor.constraint(equalTo: view.rightAnchor),
            variantsTableView.leftAnchor.constraint(equalTo: view.leftAnchor),
        ])
    }
    
    private func fillFrom(task: Task) {
        if task.deadlineDate != nil {
            let leftBarButton = UIBarButtonItem(title: "Удалить", style: .done, target: self, action: #selector(tapButtonDelete))
            leftBarButton.tintColor = InterfaceColors.textRed
            navigationItem.leftBarButtonItem = leftBarButton
        }
        
        let rightBarButton = UIBarButtonItem(title: "Готово", style: .done, target: self, action: #selector(tapButtonReady))
        rightBarButton.tintColor = InterfaceColors.textBlue
        navigationItem.rightBarButtonItem = rightBarButton
        
        if let taskDeadlineDate = task.deadlineDate {
            for variantCellValue in variantsCellValuesArray {
                guard let deadlineVariantCellValue = variantCellValue as? DeadlineVariantCellValue else {
                    break
                }
                
                if deadlineVariantCellValue.date.isEqualDate(date2: taskDeadlineDate) {
                    variantCellValue.isSelected = true
                    
                    break
                }
            }
        }
    }
    
    private static func fillCellsValues() -> [BaseDealineVariantCellValue] {
        var cellValuesArray = [BaseDealineVariantCellValue]()
        
        var today = Date()
        today = today.setComponents(hours: 12, minutes: 0, seconds: 0)
        
        cellValuesArray.append(
            DeadlineVariantCellValue(
                imageSettings: DeadlineVariantCellValue.ImageSettings(name: "calendar.badge.clock"),
                title: "Сегодня",
                date: today,
                additionalText: today.formatWith(dateFormat: "EE")
            )
        )
        
        var tomorrow = Date()
        tomorrow = tomorrow.setComponents(hours: 12, minutes: 0, seconds: 0)
        tomorrow = tomorrow.add(days: 1)
        
        cellValuesArray.append(
            DeadlineVariantCellValue(
                imageSettings: DeadlineVariantCellValue.ImageSettings(name: "arrow.right.square", size: 20),
                title: "Завтра",
                date: tomorrow,
                additionalText: tomorrow.formatWith(dateFormat: "EE")
            )
        )
        
        cellValuesArray.append(
            DeadlineVariantCellValue(
                imageSettings: DeadlineVariantCellValue.ImageSettings(name: "calendar.day.timeline.right"),
                title: "Следующая неделя (завтра)",
                date: tomorrow,
                additionalText: today.formatWith(dateFormat: "EE")
            )
        )
        
        cellValuesArray.append(
            DealineCustomCellValue(
                imageSettings: DeadlineVariantCellValue.ImageSettings(name: "calendar"),
                title: "Выбрать дату"
            )
        )
        
        return cellValuesArray
    }
    
    
    // MARK: action-handlers
    @objc private func tapButtonReady() {
        dismiss(animated: true)
    }
    
    @objc private func tapButtonDelete() {
        task.deadlineDate = nil
        taskEm.saveContext()
        
        dismiss(animated: true)
    }
}


// MARK: table delegate & datasource
extension DeadlineVariantsViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return variantsCellValuesArray.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cellValue = variantsCellValuesArray[indexPath.row]
        let cell = tableView.dequeueReusableCell(withIdentifier: TaskSettingsFieldTableViewCell.identifier)!
        
        if let taskFieldSettingsCell = cell as? TaskSettingsFieldTableViewCell {
            taskFieldSettingsCell.textLabel?.text = cellValue.title
            taskFieldSettingsCell.createAndSetImage(
                with: cellValue.imageSettings.name,
                pointSize: Float(cellValue.imageSettings.size),
                weight: cellValue.imageSettings.weight
            )
            
            switch cellValue {
            case let variantCellValue as DeadlineVariantCellValue:
                taskFieldSettingsCell.detailTextLabel?.text = variantCellValue.additionalText
                taskFieldSettingsCell.state = variantCellValue.isSelected ? .defined : .undefined
                
            case _ as DealineCustomCellValue:
                taskFieldSettingsCell.accessoryType = .disclosureIndicator
                
            default:
                break
            }
        }
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let cellValue = variantsCellValuesArray[indexPath.row]
        
        switch cellValue {
        case let deadlineVariantCellValue as DeadlineVariantCellValue:
            taskEm.updateField(deadlineDate: deadlineVariantCellValue.date, task: task)
            
            dismiss(animated: true)
            
            break
        default:
            break
            
        }
        
        tableView.deselectRow(at: indexPath, animated: true)
        
    }
}


// MARK: controller delegate protocol
/// Протокол относится к DeadlineVariantsViewController и DeadlineCustomDateViewController
protocol DeadlineSettingsViewControllerDelegate: AnyObject {
    func didDisappearDeadlineSettingsViewController(isSuccess: Bool)
}


// MARK: detent identifier
typealias SheetDetentIdentifier = UISheetPresentationController.Detent.Identifier

extension UISheetPresentationController.Detent.Identifier {
    static let taskDeadlineSettings: SheetDetentIdentifier = SheetDetentIdentifier("taskDeadlineSettings")
}


// MARK: cell values objects
class BaseDealineVariantCellValue {
    struct ImageSettings {
        var name: String
        var size: Int = 18
        var weight: UIImage.SymbolWeight = .medium
    }
    
    var imageSettings: ImageSettings
    var title: String
    var isSelected: Bool = false
    
    init(imageSettings: ImageSettings, title: String) {
        self.imageSettings = imageSettings
        self.title = title
    }
}

class DeadlineVariantCellValue: BaseDealineVariantCellValue {
    var date: Date
    var additionalText: String?
    
    init(imageSettings: ImageSettings, title: String, date: Date, additionalText: String? = nil) {
        self.date = date
        
        super.init(imageSettings: imageSettings, title: title)
        
        self.additionalText = additionalText
    }
}

class DealineCustomCellValue: BaseDealineVariantCellValue  {
}
