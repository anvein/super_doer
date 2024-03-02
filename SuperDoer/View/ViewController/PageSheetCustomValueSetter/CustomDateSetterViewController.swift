
import UIKit

/// Контроллер  в виде PageSheet для выбора  кастомной даты
class CustomDateSetterViewController: UIViewController {
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
    
    private var viewModel: CustomDateSetterViewModelType
    
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
    
    weak var delegate: CustomDateSetterViewControllerDelegate?
    
    /// Индентификатор для случая, чтобы различать из какого ViewController'а были вызваны методы делегата
    /// Например: из того, который устанавливает дату дедлайна задачи или который уст. дату и время напоминания
    var identifier: String
    
    
    // MARK: init
    init(viewModel: CustomDateSetterViewModelType, identifier: String, datePickerMode: SupportedDatePickerMode = .date) {
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
        setupNavigationBar()
        addControlsAsSubviews()
        setupConstraints()
        setupBindings()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        updateDetent()
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
    
        // TODO: разобраться надо ли это делать?
        if navigationController != nil {
            modalPresentationStyle = .pageSheet
        }
        
        // sheetPresentationController
        if let sheet = sheetPresentationController {
            sheet.widthFollowsPreferredContentSizeWhenEdgeAttached = true
            sheet.prefersGrabberVisible = true
            sheet.preferredCornerRadius = 15
        }
        
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
            navigationItem.title = title
        } else {
            let navItem = UINavigationItem()
            navItem.title = title
            navItem.rightBarButtonItem = buildReadyBarButton()
            navItem.leftBarButtonItem = buildDeleteBarButton()
            
            navigationBar.items = [navItem]
        }
    }
    
    private func buildReadyBarButton() -> UIBarButtonItem {
        let readyBarButton = UIBarButtonItem(title: "Установить", style: .done, target: self, action: #selector(tapButtonReady))
        readyBarButton.tintColor = InterfaceColors.textBlue
        
        return readyBarButton
    }
    
    private func buildDeleteBarButton() -> UIBarButtonItem {
        let deleteBarButton = UIBarButtonItem(title: "Удалить", style: .done, target: self, action: #selector(tapButtonDelete))
        deleteBarButton.tintColor = InterfaceColors.textRed
        
        return deleteBarButton
    }
    
    private func updateDetent() {
        guard let sheet = sheetPresentationController else { return }
        let detent = self.buildDetentForDatePickerMode(self.datePickerMode)
        sheet.detents = [
            detent
        ]
        
        // TODO: не дает анимировать detent из-за DatePicket - почему?
        sheet.selectedDetentIdentifier = detent.identifier
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
        
        viewModel.isShowDeleteButton.bindAndUpdateValue { [unowned self] isShowDeleteButton in
            if self.navigationController != nil {
                self.navigationItem.leftBarButtonItem?.isHidden = !isShowDeleteButton
            } else {
                self.navigationBar.topItem?.leftBarButtonItem?.isHidden = !isShowDeleteButton
            }
        }
        
        viewModel.isShowReadyButton.bindAndUpdateValue { [unowned self] isShowReadyButton in
            if self.navigationController != nil {
                self.navigationItem.rightBarButtonItem?.isHidden = !isShowReadyButton
            } else {
                self.navigationBar.topItem?.rightBarButtonItem?.isHidden = !isShowReadyButton
            }
        }
    }
    
    
    // MARK: action-handlers
    @objc private func tapButtonReady() {
        delegate?.didChooseCustomDateReady?(newDate: datePicker.date, identifier: identifier)
        dismiss(animated: true)
    }
    
    @objc private func tapButtonDelete() {
        delegate?.didChooseCustomDateDelete?(identifier: identifier)
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
@objc protocol CustomDateSetterViewControllerDelegate: AnyObject {
    /// Была нажата кнопка "Готово" (установить) - выбрана дата
    /// - Parameters:
    ///   - newDate: Date - если нажата кнопка "Готово" (установить), nil - если нажата кнопка "Удалить" (очистить)
    ///   - identifier: идентификатор открытого экземпляра контроллера (связан с полем, для которого он открыт)
    @objc optional func didChooseCustomDateReady(newDate: Date?, identifier: String)
    
    /// Была нажата кнопка "Удалить" (очистить)
    /// - Parameters:
    ///   - identifier: идентификатор открытого экземпляра контроллера (связан с полем, для которого он открыт)
    @objc optional func didChooseCustomDateDelete(identifier: String)
}