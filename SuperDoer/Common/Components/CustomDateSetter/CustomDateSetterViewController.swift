import UIKit
import RxSwift

class CustomDateSetterViewController: UIViewController {

    private let disposeBag = DisposeBag()

    private var viewModel: CustomDateSetterViewModelType
    
    private var datePickerMode: SupportedDatePickerMode
    private lazy var datePicker = UIDatePicker(frame: .zero)
    
    // MARK: - Init

    init(
        viewModel: CustomDateSetterViewModelType,
        datePickerMode: SupportedDatePickerMode = .date
    ) {
        self.viewModel = viewModel
        self.datePickerMode = datePickerMode
        
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
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        setupNavigationBarDidAppear()
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        
        if isMovingFromParent {
//            coordinator?.didGoBackCustomDateSetter?()
        }
    }

}

extension CustomDateSetterViewController {

    // MARK: - Setup

    private func setupHierarchyAndConstraints() {
        view.addSubview(datePicker)

        NSLayoutConstraint.activate([
            datePicker.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            datePicker.leadingAnchor.constraint(equalTo: view.layoutMarginsGuide.leadingAnchor),
            datePicker.trailingAnchor.constraint(equalTo: view.layoutMarginsGuide.trailingAnchor),
        ])
    }
    
    private func setupView() {
        view.backgroundColor = .Common.white

        if let sheet = sheetPresentationController {
            sheet.widthFollowsPreferredContentSizeWhenEdgeAttached = true
            sheet.prefersGrabberVisible = true
            sheet.preferredCornerRadius = 15
        }
        
        datePicker.translatesAutoresizingMaskIntoConstraints = false
        datePicker.datePickerMode = datePickerMode.datePickerMode
        datePicker.preferredDatePickerStyle = .inline
        datePicker.tintColor = .Text.blue
        datePicker.locale = .current
    }

    private func setupBindings() {
        // V -> VM
        datePicker.rx.date
            .skip(1)
            .subscribe(onNext: { [weak self] date in
            self?.viewModel.inputEvents.accept(.didSelectDate(date))
        })
        .disposed(by: disposeBag)

        // VM -> V
        viewModel.date.drive(onNext: { [weak self] value in
            guard let self, self.datePicker.date != value else { return }
            self.datePicker.date = value
        })
        .disposed(by: disposeBag)

        viewModel.isShowDeleteButton.drive(onNext: { [weak self] isShow in
            self?.navigationItem.leftBarButtonItem?.isHidden = !isShow
        })
        .disposed(by: disposeBag)

        viewModel.isShowReadyButton.drive(onNext: { [weak self] isShow in
            self?.navigationItem.rightBarButtonItem?.isHidden = !isShow
        })
        .disposed(by: disposeBag)
    }

    private func setupNavigationBarDidAppear() {
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
        let detent = datePickerMode.detent
        sheet.detents = [detent]
        sheet.selectedDetentIdentifier = detent.identifier
    }

    // MARK: - Actions handlers

    @objc private func tapButtonReady() {
        viewModel.inputEvents.accept(.didTapReady)
    }

    @objc private func tapButtonDelete() {
        viewModel.inputEvents.accept(.didTapDelete)
    }

}

// MARK: - SupportedDatePickerMode

extension CustomDateSetterViewController {
    enum SupportedDatePickerMode {
        case date
        case dateAndTime

        var datePickerMode: UIDatePicker.Mode {
            switch self {
            case .date :
                return UIDatePicker.Mode.date
            case .dateAndTime :
                return UIDatePicker.Mode.dateAndTime
            }
        }

        var detent: UISheetPresentationController.Detent {
            switch self {
            case .date:
                return .custom(identifier: .pageSheetCustomDate) { _ in 410 }
            case .dateAndTime:
                return .custom(identifier: .pageSheetCustomDateAndTime) { _ in 470 }
            }
        }
    }

}

// MARK: - Detent

extension UISheetPresentationController.Detent.Identifier {
    typealias SheetDetentIdentifier = UISheetPresentationController.Detent.Identifier

    static let pageSheetCustomDate: SheetDetentIdentifier = SheetDetentIdentifier("pageSheetCustomDate")
    static let pageSheetCustomDateAndTime: SheetDetentIdentifier = SheetDetentIdentifier("pageSheetCustomDateAndTime")
}
