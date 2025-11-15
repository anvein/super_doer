import UIKit
import RxSwift

class RepeatPeriodSelectorViewController: UIViewController {

    private let viewModel: RepeatPeriodSelectorViewModelType
    private let disposeBag = DisposeBag()

    // MARK: - Subviews

    private lazy var pickerView = UIPickerView()
    private let daysOfWeekSelectorView = DaysOfWeekRangeButtons()

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
}

private extension RepeatPeriodSelectorViewController {

    // MARK: - Setup

    func setupHierarchyAndConstraints() {
        view.addSubviews(pickerView, daysOfWeekSelectorView)

        pickerView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            pickerView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            pickerView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor),
            pickerView.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor),
        ])

        daysOfWeekSelectorView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            daysOfWeekSelectorView.topAnchor.constraint(equalTo: pickerView.bottomAnchor, constant: 20),
            daysOfWeekSelectorView.leadingAnchor
                .constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 16),
            daysOfWeekSelectorView.trailingAnchor
                .constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -16),
            daysOfWeekSelectorView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor),
            daysOfWeekSelectorView.heightAnchor.constraint(equalToConstant: 50),
        ])
    }

    func setupView() {
        view.backgroundColor = .Common.white

        let readyBarButton = UIBarButtonItem(
            title: "Установить",
            style: .done,
            target: self,
            action: #selector(handleTapReadyButton)
        )
        readyBarButton.tintColor = .Text.blue
        navigationItem.rightBarButtonItem = readyBarButton

        pickerView.dataSource = self
        pickerView.delegate = self

        daysOfWeekSelectorView.clipsToBounds = true
        daysOfWeekSelectorView.updateContent(values: viewModel.getSelectedDaysOfWeekViewModels())
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
        // V -> VM
        pickerView.rx.itemSelected
            .subscribe(onNext: { [weak self] (row: Int, component: Int) in
                self?.viewModel.inputEventRelay.accept(
                    .onChangedPickerValue(rowIndex: row, componentIndex: component)
                )
            })
            .disposed(by: disposeBag)

        daysOfWeekSelectorView.onTapButtonEvent.emit(onNext: { [weak self] itemViewModel in
            self?.viewModel.inputEventRelay.accept(.didTapDayOfWeek(itemViewModel))
        })
        .disposed(by: disposeBag)

        // VM -> V
        viewModel.isShowReadyButton.drive(onNext: { [weak self] isShow in
            guard let self else { return }
            self.navigationItem.rightBarButtonItem?.isHidden = !isShow
        })
        .disposed(by: disposeBag)

        viewModel.isShowDaysOfWeek.drive(onNext: { [weak self] isShow in
            self?.daysOfWeekSelectorView.isHidden = !isShow
        })
        .disposed(by: disposeBag)

        viewModel.amountSelectedIndex.drive(onNext: { [weak self] valueIndex in
            guard let componentIndex = self?.viewModel.getComponentIndex(.amount) else { return }
            self?.pickerView.selectRow(valueIndex ?? 0, inComponent: componentIndex, animated: true)
        })
        .disposed(by: disposeBag)

        viewModel.unitSelectedIndex.drive(onNext: { [weak self] valueIndex in
            guard let componentIndex = self?.viewModel.getComponentIndex(.unit) else { return }
            self?.pickerView.selectRow(valueIndex ?? 0, inComponent: componentIndex, animated: true)
        })
        .disposed(by: disposeBag)

        viewModel.daysOfWeekSelectedIndexes.drive(onNext: { [weak self] indexes in
            self?.daysOfWeekSelectorView.updateSelectedValues(by: indexes)
        })
        .disposed(by: disposeBag)
    }

    // MARK: - Actions handlers

    @objc private func handleTapReadyButton() {
        viewModel.inputEventRelay.accept(.didTapReadyButton)
    }
}

// MARK: - UIPickerViewDataSource

extension RepeatPeriodSelectorViewController: UIPickerViewDataSource {
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return viewModel.getComponentsCount()
    }

    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return viewModel.getRowsCountInComponent(with: component)
    }
}

// MARK: - UIPickerViewDelegate

extension RepeatPeriodSelectorViewController: UIPickerViewDelegate {

    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return viewModel.getComponentRowTitle(forRow: row, forComponent: component)
    }
}

// MARK: - Detent

extension UISheetPresentationController.Detent.Identifier {
    static let pageSheetCustomTaskRepeatPeriod: SheetDetentIdentifier = SheetDetentIdentifier("pageSheetCustomTaskRepeatPeriod")
}
