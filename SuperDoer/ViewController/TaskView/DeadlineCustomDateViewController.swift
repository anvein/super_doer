
import UIKit

/// Контролле для установки кастомной даты в поле "Срок"
class DeadlineCustomDateViewController: UIViewController {

    var task: Task
    
    var taskEm = TaskEntityManager()
    
    let datePicker = UIDatePicker(frame: .zero)
    
    weak var delegate: DeadlineSettingsViewControllerDelegate?
    
    
    // MARK: init
    init(task: Task) {
        self.task = task
        
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
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        configureSheetPresentationController()
        fillFrom(task: task)
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
        datePicker.datePickerMode = .date
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
            sheet.presentedViewController.additionalSafeAreaInsets.top = 0
            sheet.detents = [
                .custom(identifier: .taskDeadlineCustomDate, resolver: { context in
                    return 410
                })
            ]
            
            sheet.selectedDetentIdentifier = .taskDeadlineCustomDate
        }
    }
    
    private func fillFrom(task: Task) {
        datePicker.date = task.deadlineDate ?? Date()
    }
    
    
    // MARK: action-handlers
    @objc private func tapButtonReady() {
        delegate?.didChooseDeadlineDate(newDate: datePicker.date)
        
        dismiss(animated: true)
    }
}



