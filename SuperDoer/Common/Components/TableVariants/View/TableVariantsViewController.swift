import UIKit
import Foundation
import RxSwift

final class TableVariantsViewController: UIViewController {

    private let disposeBag = DisposeBag()

    private var viewModel: any TableVariantsViewModelInputOutput
    private let detent: TableVariantsControllerDetent

    private lazy var variantsTableView = VariantsTableView()
    
    // MARK: - Init

    init(
        viewModel: any TableVariantsViewModelInputOutput,
        detent: TableVariantsControllerDetent,
        title: String?
    ) {
        self.viewModel = viewModel
        self.detent = detent
        super.init(nibName: nil, bundle: nil)
        self.title = title
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
        configureSheetPresentationController()
    }
    
}

private extension TableVariantsViewController {

    // MARK: - Setup

    func setupView() {
        view.backgroundColor = .Common.white
        // TODO: заголовок (title) в ночном режиме не виден (он белый)

        variantsTableView.dataSource = self
        variantsTableView.delegate = self

        setupNavigationBar()
    }

    func setupNavigationBar() {
        let deleteBarButton = UIBarButtonItem(title: "Удалить", style: .done, target: self, action: #selector(tapButtonDelete))
        deleteBarButton.tintColor = .Text.red
        navigationItem.leftBarButtonItem = deleteBarButton

        let readyBarButton = UIBarButtonItem(title: "Готово", style: .done, target: self, action: #selector(tapButtonReady))
        readyBarButton.tintColor = .Text.blue
        navigationItem.rightBarButtonItem = readyBarButton

        if let naviBar = navigationController?.navigationBar {
            naviBar.standardAppearance.backgroundColor = .Common.white
            naviBar.titleTextAttributes = [
                .font: UIFont.systemFont(ofSize: 18, weight: .semibold),
                .foregroundColor: UIColor.Text.black
            ]
        }
    }

    func configureSheetPresentationController() {
        guard let sheet = sheetPresentationController else { return }
        sheet.detents = [detent.detent]
        sheet.animateChanges {
            sheet.selectedDetentIdentifier = detent.identifier
        }
    }


    func setupHierarchyAndConstraints() {
        view.addSubview(variantsTableView)

        NSLayoutConstraint.activate([
            variantsTableView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            variantsTableView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor),
            variantsTableView.rightAnchor.constraint(equalTo: view.rightAnchor),
            variantsTableView.leftAnchor.constraint(equalTo: view.leftAnchor),
        ])
    }
    
    func setupBindings() {
        // VM -> V
        viewModel.tableNeedReload.emit(onNext: { [weak self] _ in
            self?.variantsTableView.reloadData()
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

    // MARK: - Actions handlers

    @objc func tapButtonReady() {
        viewModel.didTapReady()
    }

    @objc func tapButtonDelete() {
        viewModel.didTapDelete()
    }

}

// MARK: - UITableViewDelegate, UITableViewDataSource

extension TableVariantsViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return viewModel.getCountVariants()
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueCell(VariantTableViewCell.self) else { return .init() }

        if let cellVM = viewModel.getVariantCellViewModel(for: indexPath)  {
            cell.fill(from: cellVM)
        }

        return cell
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        viewModel.didTapSelectVariant(with: indexPath)
        tableView.deselectRow(at: indexPath, animated: false)
    }
}
