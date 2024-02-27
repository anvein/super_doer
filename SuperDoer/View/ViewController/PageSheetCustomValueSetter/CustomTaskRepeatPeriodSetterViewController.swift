
import UIKit

/// Контроллер  в виде PageSheet для выбора  кастомного периода повтора задачи
class CustomTaskRepeatPeriodSetterViewController: UIViewController {

    private var viewModel: CustomTaskRepeatPeriodSetterViewModel
    
    private lazy var pickerView = UIPickerView()
    
    weak var delegate: CustomTaskRepeatPeriodSetterViewControllerDelegate?
    
    /// Индентификатор для случая, чтобы различать из какого ViewController'а были вызваны методы делегата
    var identifier: String
    
    
    // MARK: init
    init(viewModel: CustomTaskRepeatPeriodSetterViewModel, identifier: String) {
        self.viewModel = viewModel
        self.identifier = identifier
        
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
    
    
    // MARK: setup
    private func addControlsAsSubviews() {
        view.addSubview(pickerView)
    }
    
    private func setupConstraints() {
        NSLayoutConstraint.activate([
            pickerView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            pickerView.leadingAnchor.constraint(equalTo: view.layoutMarginsGuide.leadingAnchor),
            pickerView.trailingAnchor.constraint(equalTo: view.layoutMarginsGuide.trailingAnchor),
            pickerView.heightAnchor.constraint(equalToConstant: 200),
        ])
    }
    
    private func setupControls() {
        // self view
        view.backgroundColor = InterfaceColors.white
        
        // readyBarButton
        let readyBarButton = UIBarButtonItem(title: "Установить", style: .done, target: self, action: #selector(tapButtonReady))
        readyBarButton.tintColor = InterfaceColors.textBlue
        navigationItem.rightBarButtonItem = readyBarButton
    
        setupPickerView()
    }
    
    private func setupPickerView() {
        pickerView.translatesAutoresizingMaskIntoConstraints = false
        pickerView.dataSource = self
//        pickerView.datePickerMode = datePickerMode.asUIDatePickerMode
//        pickerView.preferredDatePickerStyle = .inline
//        pickerView.tintColor = InterfaceColors.textBlue
//        pickerView.locale = .current
    }
    
    private func configureSheetPresentationController() {
        // modalPresentationStyle = .pageSheet
        // почему это не надо делать?
        // это значение по умолчанию?
        
        if let sheet = sheetPresentationController {
            sheet.detents = [
                .custom(identifier: .pageSheetCustomTaskRepeatPeriod, resolver: { context in
                    return 410
                })
            ]
            
            sheet.widthFollowsPreferredContentSizeWhenEdgeAttached = true
            sheet.prefersGrabberVisible = true
            sheet.presentedViewController.additionalSafeAreaInsets.top = 0
            sheet.selectedDetentIdentifier = .pageSheetCustomTaskRepeatPeriod
        }
    }
    
    private func setupBindings() {
        // TODO: сделать биндинг через делегата
    }
    
    
    // MARK: action-handlers
    @objc private func tapButtonReady() {
        delegate?.didChooseCustomTaskRepeatPeriodReady(newPeriod: "", identifier: identifier)
        dismiss(animated: true)
    }
}


// MARK: date picker delegate and data source
extension CustomTaskRepeatPeriodSetterViewController: UIPickerViewDataSource, UIPickerViewDelegate {
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 2
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return 10
    }
    
    
}


// MARK: detent identifier for ViewController
extension UISheetPresentationController.Detent.Identifier {
    static let pageSheetCustomTaskRepeatPeriod: SheetDetentIdentifier = SheetDetentIdentifier("pageSheetCustomTaskRepeatPeriod")
}


// MARK: controller delegate protocol
protocol CustomTaskRepeatPeriodSetterViewControllerDelegate: AnyObject {
    /// Была нажата кнопка "Готово" (установить) - выбрана дата
    /// - Parameters:
    ///   - newPeriod: String - если нажата кнопка "Готово" (установить), nil - если нажата кнопка "Удалить" (очистить)
    ///   - identifier: идентификатор открытого экземпляра контроллера (связан с полем, для которого он открыт)
    func didChooseCustomTaskRepeatPeriodReady(newPeriod: String?, identifier: String)
}
