
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
    
    private var viewModel: CustomDateViewModel
    
    private var datePickerMode: SupportedDatePickerMode
    private lazy var datePicker = UIDatePicker(frame: .zero)
    
    weak var delegate: PageSheetCustomDateViewControllerDelegate?
    
    
    // MARK: init
    init(viewModel: CustomDateViewModel, datePickerMode: SupportedDatePickerMode = .date) {
        self.viewModel = viewModel
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
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(true)
//        navigationController?.navigationBar.topItem?.backBarButtonItem = UIBarButtonItem(title: "<<", style: .plain, target: nil, action: nil)
    }
    
    // MARK: setup
    private func addControlsAsSubviews() {
        view.addSubview(datePicker)
    }
    
    private func setupConstraints() {
        NSLayoutConstraint.activate([
            datePicker.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            datePicker.leadingAnchor.constraint(equalTo: view.layoutMarginsGuide.leadingAnchor),
            datePicker.trailingAnchor.constraint(equalTo: view.layoutMarginsGuide.trailingAnchor),
//            datePicker.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor)
        ])
    }
    
    private func setupControls() {
        view.backgroundColor = InterfaceColors.white
    
        setupDatePicker()
        setupReadyButton()
    }
    
    private func setupDatePicker() {
        datePicker.translatesAutoresizingMaskIntoConstraints = false
        datePicker.datePickerMode = datePickerMode.asUIDatePickerMode
        datePicker.preferredDatePickerStyle = .inline
        datePicker.tintColor = InterfaceColors.textBlue
        datePicker.locale = .current
    }
    
    private func setupReadyButton() {
        let rightBarButton = UIBarButtonItem(title: "Установить", style: .done, target: self, action: #selector(tapButtonReady))
        rightBarButton.tintColor = InterfaceColors.textBlue
        navigationItem.rightBarButtonItem = rightBarButton
    }
    
    private func configureSheetPresentationController() {
        if let sheet = sheetPresentationController {
            sheet.detents = [
                self.buildDetentForDatePickerMode(self.datePickerMode)
            ]
            
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
            self.datePicker.date = date ?? Date()
        }
    }
    
    
    // MARK: action-handlers
    @objc private func tapButtonReady() {
        delegate?.didChooseDate(newDate: datePicker.date)
        
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
    func didChooseDate(newDate: Date?)
}

