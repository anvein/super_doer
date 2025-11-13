import UIKit

class RepeatPeriodSelectorViewController: UIViewController {

    private let viewModel: RepeatPeriodSelectorViewModel

    // MARK: - Subviews

    private lazy var pickerView = UIPickerView()

    // MARK: - Init

    init(viewModel: RepeatPeriodSelectorViewModel) {
        self.viewModel = viewModel

        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()

        setupHierarchyAndConstraints()
        setupView()
        setupBindings()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        updateDetent()
    }

    // MARK: - Actions handlers

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

private extension RepeatPeriodSelectorViewController {

    // MARK: - Setup

    func setupHierarchyAndConstraints() {
        view.addSubview(pickerView)

        NSLayoutConstraint.activate([
            pickerView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            pickerView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor),
            pickerView.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor),
            pickerView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor),
        ])
    }

    func setupView() {
        view.backgroundColor = .Common.white

        let readyBarButton = UIBarButtonItem(
            title: "Установить",
            style: .done,
            target: self,
            action: #selector(tapButtonReady)
        )
        readyBarButton.tintColor = .Text.blue
        navigationItem.rightBarButtonItem = readyBarButton

        pickerView.translatesAutoresizingMaskIntoConstraints = false
        pickerView.dataSource = self
        pickerView.delegate = self
    }

    func updateDetent() {
        guard let sheet = sheetPresentationController else { return }

        sheet.detents = [
            .custom(identifier: .pageSheetCustomTaskRepeatPeriod) { _ in 360 },
        ]
        sheet.animateChanges {
            sheet.selectedDetentIdentifier = .pageSheetCustomTaskRepeatPeriod
        }
    }

    func setupBindings() {
        viewModel.bindingDelegate = self
    }
}


// - MARK: date picker delegate and data source
extension RepeatPeriodSelectorViewController: UIPickerViewDataSource, UIPickerViewDelegate {
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
extension RepeatPeriodSelectorViewController: CustomTaskRepeatPeriodSetterViewModelBindingDelegate {
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

// MARK: - Detent

extension UISheetPresentationController.Detent.Identifier {
    static let pageSheetCustomTaskRepeatPeriod: SheetDetentIdentifier = SheetDetentIdentifier("pageSheetCustomTaskRepeatPeriod")
}
