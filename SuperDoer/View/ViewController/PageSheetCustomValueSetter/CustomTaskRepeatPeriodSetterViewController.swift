
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
        
        updateDetent()
    }
    
    
    // MARK: setup
    private func addControlsAsSubviews() {
        view.addSubview(pickerView)
    }
    
    private func setupConstraints() {
        NSLayoutConstraint.activate([
            pickerView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            pickerView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor),
            pickerView.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor),
            pickerView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor),
        ])
    }
    
    private func setupControls() {
        // self view
        view.backgroundColor = InterfaceColors.white
        
        // readyBarButton
        let readyBarButton = UIBarButtonItem(title: "Установить", style: .done, target: self, action: #selector(tapButtonReady))
        readyBarButton.tintColor = InterfaceColors.textBlue
        navigationItem.rightBarButtonItem = readyBarButton
    
        // sheetPresentationController
        modalPresentationStyle = .pageSheet
        if let sheet = sheetPresentationController {
            sheet.widthFollowsPreferredContentSizeWhenEdgeAttached = true
            sheet.prefersGrabberVisible = true
            sheet.preferredCornerRadius = 15
        }
        
        setupPickerView()
    }
    
    private func setupPickerView() {
        pickerView.translatesAutoresizingMaskIntoConstraints = false
        pickerView.dataSource = self
        pickerView.delegate = self
    }
    
    private func updateDetent() {
        guard let sheet = sheetPresentationController else { return }

        sheet.detents = [
            .custom(identifier: .pageSheetCustomTaskRepeatPeriod, resolver: { context in
                return 360
            }),
        ]
        sheet.animateChanges {
            sheet.selectedDetentIdentifier = .pageSheetCustomTaskRepeatPeriod
        }
    }
    
    private func setupBindings() {
        viewModel.bindingDelegate = self
    }
    
    
    // MARK: action-handlers
    @objc private func tapButtonReady() {
        let amountRowVM = viewModel.getRowViewModel(
            forRow: pickerView.selectedRow(inComponent: 0),
            forComponent: 0
        ) as! TaskRepeatPeriodAmountRowViewModel
        
        let typeRowVM = viewModel.getRowViewModel(
            forRow: pickerView.selectedRow(inComponent: 1),
            forComponent: 1
        ) as! TaskRepeatPeriodTypeRowViewModel
        let periodValue = "\(amountRowVM.value)\(typeRowVM.value.rawValue)"
        
        delegate?.didChooseCustomTaskRepeatPeriodReady(newPeriod: periodValue, identifier: identifier)
        dismiss(animated: true)
    }
}


// MARK: date picker delegate and data source
extension CustomTaskRepeatPeriodSetterViewController: UIPickerViewDataSource, UIPickerViewDelegate {
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return viewModel.getNumberOfComponents()
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return viewModel.getNumberOfRowsInComponent(componentIndex: component)
    }
        
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        let rowViewModel = viewModel.getRowViewModel(forRow: row, forComponent: component)

        return rowViewModel?.visibleValue
    }

    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        if component == 1 {
            let rowViewModel = viewModel.getRowViewModel(forRow: row, forComponent: component)
            guard let rowViewModel = rowViewModel as? TaskRepeatPeriodTypeRowViewModel else { return }
            if rowViewModel.value == .week {
                viewModel.isShowDaysOfWeek = true
            }
        }
    }
}



// MARK: delegate ViewModel update events
extension CustomTaskRepeatPeriodSetterViewController: CustomTaskRepeatPeriodSetterViewModelBindingDelegate {
    func didUdpateIsShowReadyButton(newValue isShow: Bool) {
        navigationItem.rightBarButtonItem?.isHidden = !isShow
    }
    
    func didUpdateIsShowDaysOfWeek(newValue isShow: Bool) {
        // TODO: обновить видимость
    }
    
    func didUpdateRepeatPeriod(newValue repeatPeriod: String?) {
        // TODO: обновить значение периода из repeatPeriod
        pickerView.selectRow(1, inComponent: 0, animated: true)
        pickerView.selectRow(2, inComponent: 1, animated: true)
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

