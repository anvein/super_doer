import UIKit
import RxSwift

class SectionsListViewController: UIViewController {

    private var viewModel: SectionsListViewModelType

    private let disposeBag = DisposeBag()

    // MARK: - Subviews

    private lazy var sectionsTableView = TaskSectionsTableView()
    private lazy var createSectionPanelView = CreateSectionPanelView()

    // MARK: - Init

    init(viewModel: SectionsListViewModelType) {
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

        setupView()
        setupHierarchyAndConstraints()
        setupBinding()
        viewModel.loadInitialData()

//        // TODO: УДАЛИТЬ!!! КОД ДЛЯ РАЗРАБОТКИ!!!
//        PIXEL_PERFECT_screen.createAndSetupInstance(
//            baseView: self.view,
//            imageName: "PIXEL_PERFECT_home"
//        )
    }
}

private extension SectionsListViewController {

    // MARK: - Setup
    
    func setupView() {
        view.backgroundColor = .white
        
        sectionsTableView.delegate = self
        sectionsTableView.dataSource = self
    }
    
    func setupHierarchyAndConstraints() {
        view.addSubviews(sectionsTableView, createSectionPanelView)

        NSLayoutConstraint.activate([
            sectionsTableView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            sectionsTableView.bottomAnchor.constraint(equalTo: createSectionPanelView.topAnchor),
            sectionsTableView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor),
            sectionsTableView.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor),
        ])
        
        let bottomPanelHeightConstraint = createSectionPanelView.heightAnchor.constraint(
            equalToConstant: CreateSectionPanelView.State.base.params.panelHeight.cgFloat
        )
        createSectionPanelView.panelHeightConstraint = bottomPanelHeightConstraint
        NSLayoutConstraint.activate([
            bottomPanelHeightConstraint,
            createSectionPanelView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            createSectionPanelView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            createSectionPanelView.bottomAnchor.constraint(equalTo: view.keyboardLayoutGuide.topAnchor),
        ])
    }
    
    func setupBinding() {
        // V -> VM
        createSectionPanelView.answerSignal
            .emit { [weak self] answer in
                guard case .onConfirmCreate(let data) = answer else { return }
                self?.viewModel.didConfirmCreateCustomSection(title: data.title)
            }
            .disposed(by: disposeBag)


        // VM -> V
        viewModel.sectionsObservable.bindAndUpdateValue { [weak self] sections in
            guard let self else { return }
            UIView.transition(
                with: self.sectionsTableView,
                duration: 0.3,
                options: .transitionCrossDissolve
            ) {
                self.sectionsTableView.reloadData()
            }
        }
    }
}

// MARK: - UITableViewDataSource

extension SectionsListViewController: UITableViewDataSource {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return viewModel.getCountOfTableSections()
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return viewModel.getCountTaskSectionsInTableSection(with: section)
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: TaskSectionTableCell.identifier),
              let cell = cell as? TaskSectionTableCell else { return .init() }

        let sectionCellVM = viewModel.getTaskSectionTableCellVM(for: indexPath)

        switch sectionCellVM {
        case let sectionCustomCellVM as SectionCustomListTableCellVM :
            cell.viewModel = sectionCustomCellVM
            
        case let sectionSystemCellVM as SectionSystemListTableCellVM:
            cell.viewModel = sectionSystemCellVM
            
        default:
            break
        }
        
        return cell
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

    func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        let deleteAction = UIContextualAction(style: .destructive, title: "Удалить") {
            [weak self] _, _, completionHandler in
            self?.viewModel.didTapDeleteCustomSection(with: indexPath)
            completionHandler(true)
        }

        let symbolConfig = UIImage.SymbolConfiguration(pointSize: 16, weight: .semibold)
        deleteAction.image = UIImage(systemName: "trash")?
            .withConfiguration(symbolConfig)

        let archiveAction = UIContextualAction(style: .normal, title: "Архивировать") { [unowned self] _,_,completionHandler in
            self.viewModel.didTapArchiveCustomSection(indexPath: indexPath)
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
