
import UIKit
import Foundation

/// Контролер в виде PageSheet с таблицей  (для выбора вариантов из списка)
/// Должен открываться всегда в рамках NavigationController
class TableVariantsViewController: UIViewController {
    
    /// Коды  в соответствии с которыми настраивается контроллер
    enum SettingsCode {
        case taskDeadlineVariants
        case taskRepeatPeriodVariants
    }
    
    private weak var coordinator: TableVariantsViewControllerCoordinator?
    private var viewModel: TableVariantsViewModelType
    
    private var settingsCode: SettingsCode
    
    // MARK: controls
    private lazy var variantsTableView = VariantsTableView()
    
    
    // MARK: init
    
    /// - Parameters:
    ///   - settingsCode: код в соответствии с которым настроится контроллер (detent и т.д.)
    init(
        viewModel: TableVariantsViewModelType,
        coordinator: TableVariantsViewControllerCoordinator,
        settingsCode: SettingsCode
    ) {
        self.viewModel = viewModel
        self.coordinator = coordinator
        self.settingsCode = settingsCode
        
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
    
    
    // MARK: action-handlers
    @objc private func tapButtonReady() {
        dismiss(animated: true)
    }
    
    @objc private func tapButtonDelete() {
        coordinator?.didChooseDeleteVariantButton?()
        
        dismiss(animated: true)
    }
    
}


// MARK: - setup methods
extension TableVariantsViewController {
    
    private func setupControls() {
        setupController()
        setupNavigationBar()
        setupVariantsTable()
        setupBindings()
    }
    
    private func setupController() {
        view.backgroundColor = .Common.white
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
        guard let sheet = sheetPresentationController else { return }
        let detent = buildDetent()
        sheet.detents = [
            detent
        ]
        sheet.animateChanges {
            sheet.selectedDetentIdentifier = detent.identifier
        }
    }
    
    private func buildDetent() -> UISheetPresentationController.Detent {
        var detent: UISheetPresentationController.Detent
        switch self.settingsCode {
        case .taskDeadlineVariants:
            detent = .custom(identifier: .taskDeadlineVariants, resolver: { context in
                return 280
            })
            
        case .taskRepeatPeriodVariants:
            detent = .custom(identifier: .taskRepeatPeriodVariants, resolver: { context in
                return 380
            })
        }
        
        return detent
    }
    
    private func setupNavigationBar() {
        // deleteBarButton
        let deleteBarButton = UIBarButtonItem(title: "Удалить", style: .done, target: self, action: #selector(tapButtonDelete))
        deleteBarButton.tintColor = .Text.red
        navigationItem.leftBarButtonItem = deleteBarButton
        
        // readyBarButton
        let readyBarButton = UIBarButtonItem(title: "Готово", style: .done, target: self, action: #selector(tapButtonReady))
        readyBarButton.tintColor = .Text.blue
        navigationItem.rightBarButtonItem = readyBarButton
        
        // navigationBar
        if let naviBar = navigationController?.navigationBar {
            naviBar.standardAppearance.backgroundColor = .Common.white
            naviBar.titleTextAttributes = [
                .font: UIFont.systemFont(ofSize: 18, weight: .semibold),
                .foregroundColor: UIColor.Text.black
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
        viewModel.variantCellViewModels.bindAndUpdateValue { [weak self] variants in
            self?.variantsTableView.reloadData()
        }
        
        viewModel.isShowDeleteButton.bindAndUpdateValue { [weak self] isShowDeleteButton in
            self?.navigationItem.leftBarButtonItem?.isHidden = !isShowDeleteButton
        }
        
        viewModel.isShowReadyButton.bindAndUpdateValue { [weak self] isShowReadyButton in
            self?.navigationItem.rightBarButtonItem?.isHidden = !isShowReadyButton
        }
    }
}


// MARK: - table delegate & datasource
extension TableVariantsViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return viewModel.getCountVariants()
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: VariantTableViewCell.identifier)
        guard let cell = cell as? VariantTableViewCell else {
            // TODO: залогировать
            return UITableViewCell()
        }
        
        let cellVM = viewModel.getVariantCellViewModel(forIndexPath: indexPath)
        
        switch cellVM {
        case let dateVariantCellVM as DateVariantCellViewModel:
            cell.fillFrom(cellViewModel: dateVariantCellVM)
        
        case let taskRepeatPeriodVariantCellVM as TaskRepeatPeriodVariantCellViewModel :
            cell.fillFrom(cellViewModel: taskRepeatPeriodVariantCellVM)
            
        case let customVariantCellVM as CustomVariantCellViewModel:
            cell.fillFrom(cellViewModel: customVariantCellVM)
            
        default:
            break
        }
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let cellVM = viewModel.getVariantCellViewModel(forIndexPath: indexPath)
        
        switch cellVM {
        case let deadlineVariantVM as DateVariantCellViewModel:
            coordinator?.didChooseDateVariant?(newDate: deadlineVariantVM.date)
            dismiss(animated: true)
            
        case let taskRepeatPeriodVariantVM as TaskRepeatPeriodVariantCellViewModel:
            coordinator?.didChooseTaskRepeatPeriodVariant?(
                newRepeatPeriod: taskRepeatPeriodVariantVM.period
            )
            dismiss(animated: true)
            
        case _ as CustomVariantCellViewModel:
            coordinator?.didChooseCustomVariant?()
        default:
            break
        }
        
        tableView.deselectRow(at: indexPath, animated: false)
    }
}


// MARK: - controller coordinator protocol
@objc protocol TableVariantsViewControllerCoordinator: AnyObject {
    /// Был выбран вариант с типом "дата" из таблицы или нажата кнопка "Удалить" (очистить)
    /// Вызывается перед закрытие контроллера
    @objc optional func didChooseDateVariant(newDate: Date?)
    
    /// Был выбран вариант с типом "период повтора задачи" из таблицы или нажата кнопка "Удалить" (очистить)
    /// Вызывается перед закрытие контроллера
    @objc optional func didChooseTaskRepeatPeriodVariant(newRepeatPeriod: String?)
     // TODO: переделать на нормальное значение (а не String)
    
    /// Был выбран кастомный вариант в таблице
    @objc optional func didChooseCustomVariant()
    
    /// Была нажата кнопка "Удалить" (очистить)
    @objc optional func didChooseDeleteVariantButton()
}


// MARK: - detent identifier for controller
typealias SheetDetentIdentifier = UISheetPresentationController.Detent.Identifier

extension UISheetPresentationController.Detent.Identifier {
    static let taskDeadlineVariants: SheetDetentIdentifier = SheetDetentIdentifier("taskDeadlineVariants")
    static let taskRepeatPeriodVariants: SheetDetentIdentifier = SheetDetentIdentifier("taskRepeatPeriodVariants")
    static let defuiltVariantsController: SheetDetentIdentifier = SheetDetentIdentifier("defaultVariants")
}
