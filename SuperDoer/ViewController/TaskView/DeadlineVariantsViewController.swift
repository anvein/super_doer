
import UIKit

/// Контролер установки Срока по задаче (выбор вариантов из списка)
class DeadlineVariantsViewController: UIViewController {
   
    var task: Task
    
    var variantsCellValuesArray: [BaseDealineVariantCellValue] = DeadlineVariantsViewController.fillCellsValues()
    var variantsTableView = TaskFieldSettingsTableView()
    
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
    }
    
    private static func fillCellsValues() -> [BaseDealineVariantCellValue] {
        var cellValuesArray = [BaseDealineVariantCellValue]()
        
        cellValuesArray.append(
            DealineVariantCellValue(
                imageSettings: DealineVariantCellValue.ImageSettings(name: "calendar.badge.clock"),
                title: "Сегодня",
                date: Date(),
                additionalText: "Вт"
            )
        )
        
        cellValuesArray.append(
            DealineVariantCellValue(
                imageSettings: DealineVariantCellValue.ImageSettings(name: "arrow.right.square", size: 20),
                title: "Завтра",
                date: Date(),
                additionalText: "Ср"
            )
        )
        
        cellValuesArray.append(
            DealineVariantCellValue(
                imageSettings: DealineVariantCellValue.ImageSettings(name: "calendar.day.timeline.right"),
                title: "Следующая неделя",
                date: Date(),
                additionalText: "Пн"
            )
        )
        
        cellValuesArray.append(
            DealineCustomCellValue(
                imageSettings: DealineVariantCellValue.ImageSettings(name: "calendar"),
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
        let cell = tableView.dequeueReusableCell(withIdentifier: TaskFieldSettingsTableViewCell.identifier)!
        
        if let taskFieldSettingsCell = cell as? TaskFieldSettingsTableViewCell {
            taskFieldSettingsCell.textLabel?.text = cellValue.title
            taskFieldSettingsCell.createAndSetImage(
                with: cellValue.imageSettings.name,
                pointSize: Float(cellValue.imageSettings.size),
                weight: cellValue.imageSettings.weight
            )
            
            
            switch cellValue {
            case let variantCellValue as DealineVariantCellValue:
                taskFieldSettingsCell.detailTextLabel?.text = variantCellValue.additionalText
                
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
        case let deadlineVariantCellValue as DealineVariantCellValue:
            task.deadlineDate = deadlineVariantCellValue.date
            
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
        var isSelected: Bool = false
    }
    
    var imageSettings: ImageSettings
    var title: String
    
    init(imageSettings: ImageSettings, title: String) {
        self.imageSettings = imageSettings
        self.title = title
    }
}

class DealineVariantCellValue: BaseDealineVariantCellValue {
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



