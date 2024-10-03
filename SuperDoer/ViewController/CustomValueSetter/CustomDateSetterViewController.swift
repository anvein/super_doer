
import UIKit

/// Контроллер  в виде PageSheet для выбора  кастомной даты
/// Должен открываться всегда в рамках NavigationController
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
    
    private weak var coordinator: CustomDateSetterViewControllerCoordinator?
    private var viewModel: CustomDateSetterViewModelType
    
    private var datePickerMode: SupportedDatePickerMode
    private lazy var datePicker = UIDatePicker(frame: .zero)
    
    
    // MARK: init
    init(
        viewModel: CustomDateSetterViewModelType,
        coordinator: CustomDateSetterViewControllerCoordinator,
        datePickerMode: SupportedDatePickerMode = .date
    ) {
        self.viewModel = viewModel
        self.coordinator = coordinator
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
        
        updateDetent()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        setupNavigationBar()
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        
        if isMovingFromParent {
            coordinator?.didGoBackCustomDateSetter?()
        }
    }
    
    
    // MARK: action-handlers
    @objc private func tapButtonReady() {
        coordinator?.didChooseCustomDateReady?(
            newDate: datePicker.date
        )
        dismiss(animated: true)
    }
    
    @objc private func tapButtonDelete() {
        coordinator?.didChooseCustomDateDelete?()
        dismiss(animated: true)
    }
}

// MARK: - setup and layout
extension CustomDateSetterViewController {

    private func addControlsAsSubviews() {
        view.addSubview(datePicker)
    }
    
    private func setupConstraints() {
        NSLayoutConstraint.activate([
            datePicker.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            datePicker.leadingAnchor.constraint(equalTo: view.layoutMarginsGuide.leadingAnchor),
            datePicker.trailingAnchor.constraint(equalTo: view.layoutMarginsGuide.trailingAnchor),
        ])
    }
    
    private func setupControls() {
        view.backgroundColor = .Common.white
    
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
        datePicker.tintColor = .Text.blue
        datePicker.locale = .current
    }
    
    private func setupNavigationBar() {
        // TODO: сконфигурировать кнопку удалить
        
        if navigationController?.navigationBar.backItem == nil {
            navigationItem.leftBarButtonItem = buildDeleteBarButton()
        }
        
        navigationItem.rightBarButtonItem = buildReadyBarButton()
        navigationItem.title = title
    }
    
    private func buildReadyBarButton() -> UIBarButtonItem {
        let readyBarButton = UIBarButtonItem(
            title: "Установить",
            style: .done,
            target: self,
            action: #selector(tapButtonReady)
        )
        readyBarButton.tintColor = .Text.blue
        
        return readyBarButton
    }
    
    private func buildDeleteBarButton() -> UIBarButtonItem {
        let deleteBarButton = UIBarButtonItem(
            title: "Удалить",
            style: .done,
            target: self,
            action: #selector(tapButtonDelete)
        )
        deleteBarButton.tintColor = .Text.red

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
        viewModel.deadlineDateObservable.bindAndUpdateValue { [weak self] date in
            guard let defaultDate = self?.viewModel.defaultDate else { return }
            self?.datePicker.date = date ?? defaultDate
        }
        
        viewModel.isShowDeleteButtonObservable.bindAndUpdateValue { [weak self] isShowDeleteButton in
            self?.navigationItem.leftBarButtonItem?.isHidden = !isShowDeleteButton
        }
        
        viewModel.isShowReadyButtonObservable.bindAndUpdateValue { [weak self] isShowReadyButton in
            self?.navigationItem.rightBarButtonItem?.isHidden = !isShowReadyButton
        }
    }
}

// MARK: - detent identifier for ViewController
extension UISheetPresentationController.Detent.Identifier {
    typealias SheetDetentIdentifier = UISheetPresentationController.Detent.Identifier
    
    /// Для PageSheetCustomDateViewController (только date)
    static let pageSheetCustomDate: SheetDetentIdentifier = SheetDetentIdentifier("pageSheetCustomDate")
    
    /// Для PageSheetCustomDateViewController (date + time)
    static let pageSheetCustomDateAndTime: SheetDetentIdentifier = SheetDetentIdentifier("pageSheetCustomDateAndTime")
}


// MARK: - coordinator protocol for controller
@objc protocol CustomDateSetterViewControllerCoordinator: AnyObject {
    /// Была нажата кнопка "Готово" (установить) - выбрана дата
    @objc optional func didChooseCustomDateReady(newDate: Date?)
    
    /// Была нажата кнопка "Удалить" (очистить)
    @objc optional func didChooseCustomDateDelete()
    
    /// Вызывается, после того, как из контроллера перешли назад (на предыдущий контроллер)
    @objc optional func didGoBackCustomDateSetter()
}
