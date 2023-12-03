
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

        configureSheetPresentationController()
    }
    
    // MARK: actions
    private func showDeadlineCustomDateViewController() {
        let deadlineCustomVc = DeadlineCustomDateViewController(task: task)
        deadlineCustomVc.delegate = self.delegate
        
        navigationController?.pushViewController(deadlineCustomVc, animated: true)
    }
    
    
    // MARK: action-handlers
    @objc private func tapButtonReady() {
        dismiss(animated: true)
    }
    
    @objc private func tapButtonDelete() {
        delegate?.didChooseDeadlineDate(newDate: nil)
        
        dismiss(animated: true)
    }
    
}


// MARK: setup methods
extension DeadlineVariantsViewController {
    
    private func setupControls() {
        setupController()
        setupNavigationBar()
        setupVariantsTable()
    }
    
    private func setupController() {
        view.backgroundColor = InterfaceColors.white
        // TODO: заголовок (title) в ночном режиме не виден (он белый)

        title = "Срок"
        
        modalPresentationStyle = .pageSheet
        
        if let sheet = sheetPresentationController {
            sheet.widthFollowsPreferredContentSizeWhenEdgeAttached = true
            sheet.prefersGrabberVisible = true
            sheet.prefersEdgeAttachedInCompactHeight = true
            sheet.preferredCornerRadius = 15
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
            var variantIsSelected = false
            for variantCellValue in variantsCellValuesArray {
                guard let deadlineVariantCellValue = variantCellValue as? DeadlineVariantCellValue else {
                    continue
                }
                
                if deadlineVariantCellValue.date.isEqualDate(date2: taskDeadlineDate) {
                    variantCellValue.isSelected = true
                    variantIsSelected = true
                    
                    break
                }
            }
            
            if variantIsSelected == false {
                setIsSelectedCustomVariantCellValue()
            }
        }
    }
    
    // TODO: костыль, сделать нормально как-нить
    private func setIsSelectedCustomVariantCellValue() {
        for variantCellValue in variantsCellValuesArray {
            guard let deadlineCustomCellValue = variantCellValue as? DealineCustomCellValue else {
                continue
            }
            
            deadlineCustomCellValue.isSelected = true
            break
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
 
    private func configureSheetPresentationController() {
        if let sheet = sheetPresentationController {
            sheet.presentedViewController.additionalSafeAreaInsets.top = 14
            sheet.detents = [
                .custom(identifier: .taskDeadlineVariants, resolver: { context in
                    return 280
                }),
            ]
            sheet.selectedDetentIdentifier = .taskDeadlineVariants
        }
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
            taskFieldSettingsCell.state = cellValue.isSelected ? .defined : .undefined
            
            switch cellValue {
            case let variantCellValue as DeadlineVariantCellValue:
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
        case let deadlineVariantCellValue as DeadlineVariantCellValue:
            delegate?.didChooseDeadlineDate(newDate: deadlineVariantCellValue.date)
            dismiss(animated: true)
            
        case _ as DealineCustomCellValue:
            showDeadlineCustomDateViewController()
        default:
            break
        }
        
        tableView.deselectRow(at: indexPath, animated: false)
    }
}


// MARK: controller delegate protocol
/// Протокол относится к DeadlineVariantsViewController и DeadlineCustomDateViewController
protocol DeadlineSettingsViewControllerDelegate: AnyObject {
    func didChooseDeadlineDate(newDate: Date?)
}


// MARK: detent identifier
typealias SheetDetentIdentifier = UISheetPresentationController.Detent.Identifier

extension UISheetPresentationController.Detent.Identifier {
    /// Для DeadlineVariantsViewController
    static let taskDeadlineVariants: SheetDetentIdentifier = SheetDetentIdentifier("taskDeadlineVariants")
    
    /// Для DeadlineCustomDateViewController
    static let taskDeadlineCustomDate: SheetDetentIdentifier = SheetDetentIdentifier("taskDeadlineCustomDate")
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
