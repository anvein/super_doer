
import UIKit
import Foundation

/// Контролер в виде PageSheet с таблицей  (для выбора вариантов даты из списка)
class PageSheetTableDateVariantsViewController: UIViewController {
   
    private var viewModel: TableDateVariantsViewModelType
    
    
    // MARK: controls
    private lazy var variantsTableView = TaskSettingsFieldTableView()
    
    weak var delegate: PageSheetTableVariantsViewControllerDelegate?
    /// Индентификатор для случая, чтобы различать из какого ViewController'а были вызваны методы делегата
    /// Например: из того, который устанавливает дату дедлайна задачи или который устанавливает дату напоминания
    var identifier: String
    
    
    // MARK: init
    init(viewModel: TableDateVariantsViewModelType, identifier: String) {
        self.viewModel = viewModel
        self.identifier = identifier
        
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
        guard let viewModel = viewModel as? TaskDeadlineTableVariantsViewModel else { return }
        
        let customDateVM = viewModel.getTaskDeadlineCustomDateViewModel()
        let customDateVC = PageSheetCustomDateViewController(viewModel: customDateVM, identifier: self.identifier)
        
        if let delegate = delegate as? PageSheetCustomDateViewControllerDelegate {
            customDateVC.delegate = delegate
        }
        
        navigationController?.pushViewController(customDateVC, animated: true)
    }
    
    
    // MARK: action-handlers
    @objc private func tapButtonReady() {
        dismiss(animated: true)
    }
    
    @objc private func tapButtonDelete() {
        delegate?.didChooseDateVariant(newDate: nil, identifier: self.identifier)
        
        dismiss(animated: true)
    }
    
}


// MARK: setup methods
extension PageSheetTableDateVariantsViewController {
    
    private func setupControls() {
        setupController()
        setupNavigationBar()
        setupVariantsTable()
        setupBindings()
    }
    
    private func setupController() {
        view.backgroundColor = InterfaceColors.white
        // TODO: заголовок (title) в ночном режиме не виден (он белый)
        
        modalPresentationStyle = .pageSheet
        
        if let sheet = sheetPresentationController {
            sheet.widthFollowsPreferredContentSizeWhenEdgeAttached = true
            sheet.prefersGrabberVisible = true
            sheet.prefersEdgeAttachedInCompactHeight = true
            sheet.preferredCornerRadius = 15
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
    
    private func setupNavigationBar() {
        // deleteBarButton
        let deleteBarButton = UIBarButtonItem(title: "Удалить", style: .done, target: self, action: #selector(tapButtonDelete))
        deleteBarButton.tintColor = InterfaceColors.textRed
        navigationItem.leftBarButtonItem = deleteBarButton
        
        // readyBarButton
        let readyBarButton = UIBarButtonItem(title: "Готово", style: .done, target: self, action: #selector(tapButtonReady))
        readyBarButton.tintColor = InterfaceColors.textBlue
        navigationItem.rightBarButtonItem = readyBarButton
        
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
        
        viewModel.isShowDeleteButton.bindAndUpdateValue { [unowned self] isShowDeleteButton in
            self.navigationItem.leftBarButtonItem?.isHidden = !isShowDeleteButton
        }
    }
    
}


// MARK: table delegate & datasource
extension PageSheetTableDateVariantsViewController: UITableViewDelegate, UITableViewDataSource {
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
            case let variantCellValue as DateVariantCellValue:
                taskFieldSettingsCell.detailTextLabel?.text = variantCellValue.additionalText
                
            case _ as CustomVariantCellValue:
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
        case let deadlineVariantCellValue as DateVariantCellValue:
            delegate?.didChooseDateVariant(newDate: deadlineVariantCellValue.date, identifier: identifier)
            dismiss(animated: true)
            
        case _ as CustomVariantCellValue:
            showDeadlineCustomDateViewController()
        default:
            break
        }
        
        tableView.deselectRow(at: indexPath, animated: false)
    }
}



// MARK: controller delegate protocol
protocol PageSheetTableVariantsViewControllerDelegate: AnyObject {
    /// Был выбран вариант из таблицы или нажата кнопка "Удалить" (очистить)
    /// - Parameters:
    ///   - newDate: Date - если выбран вариант из таблицы (со значением), nil - если нажата кнопка "Удалить",
    ///   - identifier: идентификатор открытого экземпляра контроллера
    ///    (связан с полем для заполнения которорого был открыть контроллер
    func didChooseDateVariant(newDate: Date?, identifier: String)
}

// TODO: вынести / сделать изменяемыми
// MARK: detent identifier
typealias SheetDetentIdentifier = UISheetPresentationController.Detent.Identifier

extension UISheetPresentationController.Detent.Identifier {
    /// Для DeadlineVariantsViewController
    static let taskDeadlineVariants: SheetDetentIdentifier = SheetDetentIdentifier("taskDeadlineVariants")
}
