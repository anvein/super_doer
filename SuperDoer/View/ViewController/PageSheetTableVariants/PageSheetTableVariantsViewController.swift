
import UIKit
import Foundation

/// Контролер в виде PageSheet с таблицей  (для выбора вариантов из списка)
class PageSheetTableVariantsViewController: UIViewController {
    typealias TaskFieldIdentifier = TaskDetailViewController.FieldNameIdentifier
    
    private var viewModel: TableVariantsViewModelType
    
    // MARK: controls
    private lazy var variantsTableView = VariantsTableView()
    
    weak var delegate: PageSheetTableVariantsViewControllerDelegate?
    /// Индентификатор для случая, чтобы различать из какого ViewController'а были вызваны методы делегата
    /// Например: из того, который устанавливает дату дедлайна задачи или который устанавливает дату напоминания
    var identifier: String
    
    
    // MARK: init
    init(viewModel: TableVariantsViewModelType, identifier: String) {
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
    
    
    // MARK: action-handlers
    @objc private func tapButtonReady() {
        dismiss(animated: true)
    }
    
    @objc private func tapButtonDelete() {
        delegate?.didChooseDeleteVariantButton?(identifier: self.identifier)
        
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
//            sheet.presentedViewController.additionalSafeAreaInsets.top = 14
            sheet.selectedDetentIdentifier = detent.identifier
        }
    }
    
    private func buildDetent() -> UISheetPresentationController.Detent {
        var detent: UISheetPresentationController.Detent
        switch self.identifier {
        case TaskFieldIdentifier.taskDeadline.rawValue:
            detent = .custom(identifier: .taskDeadlineVariants, resolver: { context in
                return 280
            })
            
        case TaskFieldIdentifier.taskRepeatPeriod.rawValue:
            detent = .custom(identifier: .taskRepeatPeriodVariants, resolver: { context in
                return 380
            })
            
        default:
            detent = .custom(identifier: .defuiltVariantsController, resolver: { context in
                return 280
            })
        }
        
        return detent
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
        viewModel.variantCellViewModels.bindAndUpdateValue { [unowned self] variants in
            self.variantsTableView.reloadData()
        }
        
        viewModel.isShowDeleteButton.bindAndUpdateValue { [unowned self] isShowDeleteButton in
            self.navigationItem.leftBarButtonItem?.isHidden = !isShowDeleteButton
        }
        
        viewModel.isShowReadyButton.bindAndUpdateValue { [unowned self] isShowReadyButton in
            self.navigationItem.rightBarButtonItem?.isHidden = !isShowReadyButton
        }
    }
}


// MARK: table delegate & datasource
extension PageSheetTableVariantsViewController: UITableViewDelegate, UITableViewDataSource {
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
            delegate?.didChooseDateVariant?(newDate: deadlineVariantVM.date, identifier: identifier)
            dismiss(animated: true)
            
        case let taskRepeatPeriodVariantVM as TaskRepeatPeriodVariantCellViewModel:
            delegate?.didChooseTaskRepeatPeriodVariant?(newRepeatPeriod: taskRepeatPeriodVariantVM.period, identifier: identifier)
            dismiss(animated: true)
            
        case _ as CustomVariantCellViewModel:
            delegate?.didChooseCustomVariant?(navigationController: navigationController, identifier: identifier)
        default:
            break
        }
        
        tableView.deselectRow(at: indexPath, animated: false)
    }
}


// MARK: controller delegate protocol
@objc protocol PageSheetTableVariantsViewControllerDelegate: AnyObject {
    /// Был выбран вариант с типом "дата" из таблицы или нажата кнопка "Удалить" (очистить)
    /// Вызывается перед закрытие контроллера
    /// - Parameters:
    ///   - newDate: Date - если выбран вариант из таблицы (со значением), nil - если нажата кнопка "Удалить",
    ///   - identifier: идентификатор открытого экземпляра контроллера
    ///    (связан с полем для заполнения которорого был открыть контроллер
    @objc optional func didChooseDateVariant(newDate: Date?, identifier: String)
    
    // Был выбран вариант с типом "период повтора задачи" из таблицы или нажата кнопка "Удалить" (очистить)
    /// Вызывается перед закрытие контроллера
    /// - Parameters:
    ///   - newRepeatPeriod: String - если выбран вариант из таблицы (со значением), nil - если нажата кнопка "Удалить",
    ///   - identifier: идентификатор открытого экземпляра контроллера
    ///    (связан с полем для заполнения которорого был открыть контроллер
    @objc optional func didChooseTaskRepeatPeriodVariant(newRepeatPeriod: String?, identifier: String)
    // TODO: переделать на нормальное значение
    
    /// Был выбран кастомный вариант в таблице
    /// - Parameters:
    ///   - navigationController: navigationController, в рамках которого открыт контроллер с вариантами
    ///   - identifier: идентификатор открытого экземпляра контроллера
    ///    (связан с полем для заполнения которорого был открыть контроллер вариантов
    @objc optional func didChooseCustomVariant(navigationController: UINavigationController?, identifier: String)
    
    /// Была нажата кнопка "Удалить" (очистить)
    /// - Parameters:
    ///   - identifier: идентификатор открытого экземпляра контроллера
    ///    (связан с полем для заполнения которорого был открыть контроллер вариантов
    @objc optional func didChooseDeleteVariantButton(identifier: String)
}


// MARK: detent identifier for controller
typealias SheetDetentIdentifier = UISheetPresentationController.Detent.Identifier

extension UISheetPresentationController.Detent.Identifier {
    static let taskDeadlineVariants: SheetDetentIdentifier = SheetDetentIdentifier("taskDeadlineVariants")
    static let taskRepeatPeriodVariants: SheetDetentIdentifier = SheetDetentIdentifier("taskRepeatPeriodVariants")
    static let defuiltVariantsController: SheetDetentIdentifier = SheetDetentIdentifier("defaultVariants")
}
