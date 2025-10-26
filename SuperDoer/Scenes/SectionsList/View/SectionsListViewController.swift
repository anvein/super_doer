import UIKit

class SectionsListViewController: UIViewController {

    private var viewModel: SectionsListViewModelType

    // MARK: - Subviews

    private lazy var sectionsTableView = TaskSectionsTableView()
    private lazy var addSectionPanelView = AddSectionBottomPanelView()

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
        setupHierarchy()
        setupConstraints()
        setupBinding()
        viewModel.loadInitialData()

//        // TODO: УДАЛИТЬ!!! КОД ДЛЯ РАЗРАБОТКИ!!!
//        PIXEL_PERFECT_screen.createAndSetupInstance(
//            baseView: self.view,
//            imageName: "PIXEL_PERFECT_home"
//        )
    }


    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(true)

//        // TODO: УДАЛИТЬ!!! КОД ДЛЯ РАЗРАБОТКИ!!!
//        ///////////////////////////////////////////////////
//        let vm = viewModel.getTaskListViewModel(forIndexPath: IndexPath(row: 0, section: 1))
//        if let vm = vm as? TasksListViewModel {
//            coordinator?.selectTaskSection(viewModel: vm)
//        }
//        ///////////////////////////////////////////////////
    }
    
}

private extension SectionsListViewController {

    // MARK: - Setup

    func setupHierarchy() {
        view.addSubview(sectionsTableView)
        view.addSubview(addSectionPanelView)
    }
    
    func setupView() {
        view.backgroundColor = .white
        
        sectionsTableView.delegate = self
        sectionsTableView.dataSource = self
        
        addSectionPanelView.delegate = self
    }
    
    func setupConstraints() {
        NSLayoutConstraint.activate([
            sectionsTableView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            sectionsTableView.bottomAnchor.constraint(equalTo: addSectionPanelView.topAnchor),
            sectionsTableView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor),
            sectionsTableView.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor),
        ])
        
        let bottomPanelHeightConstraint = addSectionPanelView.heightAnchor.constraint(
            equalToConstant: AddSectionBottomPanelView.State.base.params.panelHeight.cgFloat
        )
        addSectionPanelView.panelHeightConstraint = bottomPanelHeightConstraint
        NSLayoutConstraint.activate([
            bottomPanelHeightConstraint,
            addSectionPanelView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            addSectionPanelView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            addSectionPanelView.bottomAnchor.constraint(equalTo: view.keyboardLayoutGuide.topAnchor),
        ])
    }
    
    func setupBinding() {
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
        let cell = tableView.dequeueReusableCell(withIdentifier: TaskSectionTableViewCell.identifier) as! TaskSectionTableViewCell
        
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
        viewModel.didSelectTaskSection(with: indexPath)
        tableView.deselectRow(at: indexPath, animated: true)
    }

    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return TaskSectionTableViewCell.cellHeight
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


// MARK: - AddSectionBottomPanelViewDelegate

extension SectionsListViewController: AddSectionBottomPanelViewDelegate {
    func createSectionWith(title: String) {
        viewModel.didConfirmCreateCustomSection(title: title)
    }
}

