
import UIKit
import Foundation

/// Контролер в виде PageSheet с таблицей  (для выбора вариантов из списка)
class PageSheetTableVariantsViewController: UIViewController {
   
    private var viewModel: VariantsViewModelType
    
    
    // MARK: controls
    private lazy var variantsTableView = TaskSettingsFieldTableView()
    
    private lazy var deleteBarButton = UIBarButtonItem()
    private lazy var readyBarButton = UIBarButtonItem()
    
    weak var delegate: PageSheetTableVariantsViewControllerDelegate?
    
    
    // MARK: init
    init(viewModel: VariantsViewModelType) {
        self.viewModel = viewModel
        
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
        setupBindings()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
    
        configureSheetPresentationController()
    }
    
    // MARK: actions
    private func showDeadlineCustomDateViewController() {
//        let deadlineCustomVc = DeadlineCustomDateViewController(task: task)
//        deadlineCustomVc.delegate = self.delegate
//        
//        navigationController?.pushViewController(deadlineCustomVc, animated: true)
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
extension PageSheetTableVariantsViewController {
    
    private func setupControls() {
        setupController()
        setupNavigationBar()
        setupVariantsTable()
        setupBindings()
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
        // deleteBarButton
        deleteBarButton.title = "Удалить"
        deleteBarButton.style = .done
        deleteBarButton.target = self
        deleteBarButton.action = #selector(tapButtonDelete)
        deleteBarButton.tintColor = InterfaceColors.textRed
        
        // readyBarButton
        readyBarButton.title = "Готово"
        readyBarButton.style = .done
        readyBarButton.target = self
        readyBarButton.action = #selector(tapButtonReady)
        readyBarButton.tintColor = InterfaceColors.textBlue
        
        // navigationBar
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
        NSLayoutConstraint.activate([
            variantsTableView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            variantsTableView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor),
            variantsTableView.rightAnchor.constraint(equalTo: view.rightAnchor),
            variantsTableView.leftAnchor.constraint(equalTo: view.leftAnchor),
        ])
    }
    
    private func setupBindings() {
        viewModel.variantsCellValuesArray.bindAndUpdateValue { [unowned self] variants in
            self.variantsTableView.reloadData()
        }
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
extension PageSheetTableVariantsViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return viewModel.getCountVariants()
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cellValue = viewModel.getVariantCellValue(forIndexPath: indexPath)
        let cell = tableView.dequeueReusableCell(withIdentifier: TaskSettingsFieldTableViewCell.identifier)!
        
        // TODO: создать метод заполнения ячейки из CellValue
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
                
            case _ as DealineCustomVariantCellValue:
                taskFieldSettingsCell.accessoryType = .disclosureIndicator
                
            default:
                break
            }
        }
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let cellValue = viewModel.getVariantCellValue(forIndexPath: indexPath)
        
        switch cellValue {
        case let deadlineVariantCellValue as DeadlineVariantCellValue:
            delegate?.didChooseDeadlineDate(newDate: deadlineVariantCellValue.date)
            dismiss(animated: true)
            
        case _ as DealineCustomVariantCellValue:
            showDeadlineCustomDateViewController()
        default:
            break
        }
        
        tableView.deselectRow(at: indexPath, animated: false)
    }
}



// MARK: controller delegate protocol
protocol PageSheetTableVariantsViewControllerDelegate: AnyObject {
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


