import UIKit

class CustomTaskRepeatPeriodSetterViewController: UIViewController {

    private var viewModel: CustomTaskRepeatPeriodSetterViewModel
    
    // MARK: controls
    private lazy var pickerView = UIPickerView()
    

    // MARK: init
    init(viewModel: CustomTaskRepeatPeriodSetterViewModel) {
        self.viewModel = viewModel
        
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
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        
        if isMovingFromParent {
//            coordinator?.didGoBackCustomRepeatPeriodSetter()
        }
    }
    
    
    // MARK: action-handlers
    @objc private func tapButtonReady() {
        let amountRowVM = viewModel.getRowViewModel(
            forRow: pickerView.selectedRow(inComponent: 0),
            forComponent: 0
        )
        guard let amountRowVM = amountRowVM as? TaskRepeatPeriodAmountRowViewModel else { return }
        
        let typeRowVM = viewModel.getRowViewModel(
            forRow: pickerView.selectedRow(inComponent: 1),
            forComponent: 1
        )
        guard let typeRowVM = typeRowVM as? TaskRepeatPeriodTypeRowViewModel else { return }
        
        let periodValue = "\(amountRowVM.value)\(typeRowVM.value.rawValue)"
//        coordinator?.didChooseCustomTaskRepeatPeriodReady(newPeriod: periodValue)
        dismiss(animated: true)
    }
}


// MARK: - setup and layout
extension CustomTaskRepeatPeriodSetterViewController {
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
        view.backgroundColor = .Common.white
        
        // readyBarButton
        let readyBarButton = UIBarButtonItem(
            title: "Установить",
            style: .done,
            target: self,
            action: #selector(tapButtonReady)
        )
        readyBarButton.tintColor = .Text.blue
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
}


// - MARK: date picker delegate and data source
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


// MARK: - delegate ViewModel update events
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


// MARK: - detent identifier for controller
extension UISheetPresentationController.Detent.Identifier {
    static let pageSheetCustomTaskRepeatPeriod: SheetDetentIdentifier = SheetDetentIdentifier("pageSheetCustomTaskRepeatPeriod")
}


// MARK: - coordinator protocol for controller
protocol CustomTaskRepeatPeriodSetterViewControllerCoordinator: AnyObject {
    /// Была нажата кнопка "Готово" (установить) - выбрана дата
    func didChooseCustomTaskRepeatPeriodReady(newPeriod: String?)
    
    ///  Вызывается, после того, как из контроллера перешли назад (на предыдущий контроллер)
    func didGoBackCustomRepeatPeriodSetter()
}

