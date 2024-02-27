
import UIKit

/// Контроллер  в виде PageSheet для выбора  кастомной даты
class PageSheetCustomDateViewController: UIViewController {
    enum SupportedDatePickerMode {
        case date
        case dateAndTime
        
        var asUIDatePickerMode: UIDatePicker.Mode {
            switch self {
            case .date :
                return UIDatePicker.Mode.date
            case .dateAndTime :
                return UIDatePicker.Mode.dateAndTime
            }
        }
    }
    
    private var viewModel: CustomDateViewModelType
    
    private var datePickerMode: SupportedDatePickerMode
    private lazy var datePicker = UIDatePicker(frame: .zero)
    
    private lazy var navigationBar: UINavigationBar = {
        let navBar = UINavigationBar()
        navBar.translatesAutoresizingMaskIntoConstraints = false
        
        let standardAppearance = UINavigationBarAppearance()
        standardAppearance.configureWithOpaqueBackground()
        standardAppearance.shadowImage = nil
        standardAppearance.shadowColor = nil
        navBar.standardAppearance = standardAppearance
    
        return navBar
    }()
    
    weak var delegate: PageSheetCustomDateViewControllerDelegate?
    
    /// Индентификатор для случая, чтобы различать из какого ViewController'а были вызваны методы делегата
    /// Например: из того, который устанавливает дату дедлайна задачи или который уст. дату и время напоминания
    var identifier: String
    
    
    // MARK: init
    init(viewModel: CustomDateViewModelType, identifier: String, datePickerMode: SupportedDatePickerMode = .date) {
        self.viewModel = viewModel
        self.identifier = identifier
        self.datePickerMode = datePickerMode
        
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
    // MARK: life-cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupControls()
        addControlsAsSubviews()
        setupConstraints()
        setupBindings()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        // TODO: анимировать изменение высоты контроллера
        configureSheetPresentationController()
        
        setupNavigationBar()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(true)
    }
    
    
    // MARK: setup
    private func addControlsAsSubviews() {
        view.addSubview(datePicker)
        
        if navigationController == nil {
            view.addSubview(navigationBar)
        }
    }
    
    private func setupConstraints() {
        NSLayoutConstraint.activate([
            datePicker.leadingAnchor.constraint(equalTo: view.layoutMarginsGuide.leadingAnchor),
            datePicker.trailingAnchor.constraint(equalTo: view.layoutMarginsGuide.trailingAnchor),
        ])
        
        if navigationController != nil {
            datePicker.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor).isActive = true
        } else {
            datePicker.topAnchor.constraint(equalTo: navigationBar.bottomAnchor).isActive = true
            
            NSLayoutConstraint.activate([
                navigationBar.topAnchor.constraint(equalTo: view.topAnchor),
                navigationBar.leadingAnchor.constraint(equalTo: view.leadingAnchor),
                navigationBar.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            ])
        }
    }
    
    private func setupControls() {
        view.backgroundColor = InterfaceColors.white
    
        setupDatePicker()
    }
    
    private func setupDatePicker() {
        datePicker.translatesAutoresizingMaskIntoConstraints = false
        datePicker.datePickerMode = datePickerMode.asUIDatePickerMode
        datePicker.preferredDatePickerStyle = .inline
        datePicker.tintColor = InterfaceColors.textBlue
        datePicker.locale = .current
    }
    
    private func setupNavigationBar() {
        if navigationController != nil {
            navigationItem.rightBarButtonItem = buildReadyBarButton()
        } else {
            let deleteBarButton = buildDeleteBarButton()
            
            let navItem = UINavigationItem()
            navItem.rightBarButtonItem = buildReadyBarButton()
            navItem.leftBarButtonItem = buildDeleteBarButton()
            
            navigationBar.items = [navItem]
        }
    }
    
    private func buildReadyBarButton() -> UIBarButtonItem? {
        guard viewModel.isShowReadyButton.value else { return nil }
        
        let readyBarButton = UIBarButtonItem(title: "Установить", style: .done, target: self, action: #selector(tapButtonReady))
        readyBarButton.tintColor = InterfaceColors.textBlue
        
        return readyBarButton
    }
    
    private func buildDeleteBarButton() -> UIBarButtonItem? {
        guard viewModel.isShowDeleteButton.value else { return nil }
        
        let deleteBarButton = UIBarButtonItem(title: "Удалить", style: .done, target: self, action: #selector(tapButtonDelete))
        deleteBarButton.tintColor = InterfaceColors.textRed
        
        return deleteBarButton
    }
    
    private func configureSheetPresentationController() {
        // modalPresentationStyle = .pageSheet
        // почему это не надо делать?
        // это значение по умолчанию?
        
        if let sheet = sheetPresentationController {
            sheet.detents = [
                self.buildDetentForDatePickerMode(self.datePickerMode)
            ]
            
            sheet.widthFollowsPreferredContentSizeWhenEdgeAttached = true
            sheet.prefersGrabberVisible = true
            sheet.presentedViewController.additionalSafeAreaInsets.top = 0
            sheet.selectedDetentIdentifier = .pageSheetCustomDate
        }
    }
    
    private func buildDetentForDatePickerMode(_ mode: SupportedDatePickerMode) -> UISheetPresentationController.Detent {
        switch mode {
        case .date:
            return .custom(identifier: .pageSheetCustomDate, resolver: { context in
                return 410
            })
        case .dateAndTime:
            return .custom(identifier: .pageSheetCustomDateAndTime, resolver: { context in
                return 470
            })
        }
    }
    
    private func setupBindings() {
        viewModel.date.bindAndUpdateValue { date in
            self.datePicker.date = date ?? self.viewModel.defaultDate
        }
    }
    
    
    // MARK: action-handlers
    @objc private func tapButtonReady() {
        delegate?.didChooseDate(newDate: datePicker.date, identifier: identifier)
        dismiss(animated: true)
    }
    
    @objc private func tapButtonDelete() {
        delegate?.didChooseDate(newDate: nil, identifier: identifier)
        dismiss(animated: true)
    }
}

// MARK: detent identifier for ViewController
extension UISheetPresentationController.Detent.Identifier {
    typealias SheetDetentIdentifier = UISheetPresentationController.Detent.Identifier
    
    /// Для PageSheetCustomDateViewController (только date)
    static let pageSheetCustomDate: SheetDetentIdentifier = SheetDetentIdentifier("pageSheetCustomDate")
    
    /// Для PageSheetCustomDateViewController (date + time)
    static let pageSheetCustomDateAndTime: SheetDetentIdentifier = SheetDetentIdentifier("pageSheetCustomDateAndTime")
}



// MARK: controller delegate protocol
protocol PageSheetCustomDateViewControllerDelegate: AnyObject {
    /// Была нажата кнопка "Готово" (установить) или  "Удалить" (очистить)
    /// - Parameters:
    ///   - newDate: Date - если нажата кнопка "Готово" (установить), nil - если нажата кнопка "Удалить" (очистить)
    ///   - identifier: идентификатор открытого экземпляра контроллера (связан с полем, для которого он открыт)
    func didChooseDate(newDate: Date?, identifier: String)
}
