import RxSwift
import UIKit
import OrderedCollections

class SectionsListViewController: UIViewController {

    private let disposeBag = DisposeBag()

    // MARK: - Data

    private var viewModel: SectionsListViewModelInout
    private var tableDataSource: UITableViewDiffableDataSource<SectionsListGroupViewModel, TaskSectionCellViewModel>?

    // MARK: - Subviews

    private lazy var sectionsTableView = TaskSectionsTableView()
    private lazy var createSectionPanelView = CreateSectionPanelView()

    // MARK: - Init

    init(viewModel: SectionsListViewModelInout) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()

        title = "Списки"

        navigationController?.navigationBar.prefersLargeTitles = true
        navigationItem.largeTitleDisplayMode = .never

        setupHierarchyAndConstraints()
        setupView()
        setupTableDataSource()
        setupBinding()
        viewModel.loadInitialData()
    }

}

extension SectionsListViewController {

    // MARK: - Setup

    fileprivate func setupView() {
        view.backgroundColor = .white
        sectionsTableView.delegate = self
    }

    fileprivate func setupHierarchyAndConstraints() {
        view.addSubviews(sectionsTableView, createSectionPanelView)

        NSLayoutConstraint.activate([
            sectionsTableView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            sectionsTableView.bottomAnchor.constraint(equalTo: createSectionPanelView.topAnchor),
            sectionsTableView.leadingAnchor.constraint(
                equalTo: view.safeAreaLayoutGuide.leadingAnchor
            ),
            sectionsTableView.trailingAnchor.constraint(
                equalTo: view.safeAreaLayoutGuide.trailingAnchor
            ),
        ])

        let bottomPanelHeightConstraint = createSectionPanelView.heightAnchor.constraint(
            equalToConstant: CreateSectionPanelView.State.base.params.panelHeight.cgFloat
        )
        createSectionPanelView.panelHeightConstraint = bottomPanelHeightConstraint
        NSLayoutConstraint.activate([
            bottomPanelHeightConstraint,
            createSectionPanelView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            createSectionPanelView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            createSectionPanelView.bottomAnchor.constraint(
                equalTo: view.keyboardLayoutGuide.topAnchor
            ),
        ])
    }

    fileprivate func setupTableDataSource() {
        tableDataSource = .init(tableView: sectionsTableView) {
            (tableView, indexPath, cellVM) -> UITableViewCell? in
            guard let cell = tableView.dequeueCell(TaskSectionTableCell.self, for: indexPath) else { return .init() }
            cell.fillFrom(cellVM: cellVM)
            return cell
        }
    }

    private func updateTableSnapshot(
        dataViewModels: OrderedDictionary<SectionsListGroupViewModel, [TaskSectionCellViewModel]>,
        withAnimation: Bool = true
    ) {
        var snapshot = NSDiffableDataSourceSnapshot<SectionsListGroupViewModel, TaskSectionCellViewModel>()
        for (listGroup, sectionsInGroup) in dataViewModels {
            snapshot.appendSections([listGroup])
            snapshot.appendItems(sectionsInGroup, toSection: listGroup)
        }

        tableDataSource?.apply(snapshot, animatingDifferences: withAnimation)
    }

    fileprivate func setupBinding() {
        // V -> VM
        createSectionPanelView.answerSignal
            .emit { [weak self] answer in
                guard case .onConfirmCreate(let data) = answer else { return }
                self?.viewModel.didConfirmCreateCustomSection(title: data.title)
            }
            .disposed(by: disposeBag)

        // VM -> V
        viewModel.didUpdatedData.emit(onNext: { [weak self] dataViewModels in
            self?.updateTableSnapshot(dataViewModels: dataViewModels)
        })
        .disposed(by: disposeBag)
    }
}

// MARK: - UITableViewDelegate

extension SectionsListViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        viewModel.didTapOpenTasksListInSection(with: indexPath)
        tableView.deselectRow(at: indexPath, animated: true)
    }

    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return TaskSectionTableCell.cellHeight
    }

    // MARK: Swipe actions

    func tableView(
        _ tableView: UITableView,
        trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath
    ) -> UISwipeActionsConfiguration? {
        let deleteAction = UIContextualAction(style: .destructive, title: "Удалить") {
            [weak self] _, _, completionHandler in
            self?.viewModel.didTapDeleteCustomSection(with: indexPath)
            completionHandler(true)
        }

        let symbolConfig = UIImage.SymbolConfiguration(pointSize: 16, weight: .semibold)
        deleteAction.image = UIImage(systemName: "trash")?
            .withConfiguration(symbolConfig)

        let archiveAction = UIContextualAction(style: .normal, title: "Архивировать") {
            [unowned self] _, _, completionHandler in
            self.viewModel.didTapArchiveCustomSection(with: indexPath)
            completionHandler(true)
        }
        archiveAction.image = UIImage(systemName: "archivebox")?
            .withConfiguration(symbolConfig)
        archiveAction.backgroundColor = .TaskCell.orangeSwipeAction

        return UISwipeActionsConfiguration(actions: [deleteAction, archiveAction])
    }

    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        return UIView()
    }

    func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        if section == 0 {
            return TaskSectionsSeparator()
        } else {
            return UIView()
        }
    }

    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return CGFloat.leastNormalMagnitude
    }

    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        if section == 0 {
            return 26
        } else {
            return CGFloat.leastNormalMagnitude
        }
    }

}
