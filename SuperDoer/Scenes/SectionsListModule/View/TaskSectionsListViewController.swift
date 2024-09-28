
import UIKit

/// Экран списков (разделов)
class TaskSectionsListViewController: UIViewController {

    private weak var coordinator: TaskSectionsListViewControllerCoordinator?
    private var viewModel: TaskSectionListViewModelType
    
     
    // MARK: controls
    private lazy var sectionsTableView = TaskSectionsTableView()
    
    private lazy var addSectionBottomPanelView = AddSectionBottomPanelView()

    
    // MARK: init
    init(
        coordinator: TaskSectionsListViewControllerCoordinator,
        viewModel: TaskSectionListViewModelType
    ) {
        self.coordinator = coordinator
        self.viewModel = viewModel
        
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
    // MARK: life cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        title = "Списки"
        
        navigationController?.navigationBar.prefersLargeTitles = true
        navigationItem.largeTitleDisplayMode = .never
        
        setupControls()
        addSubviewsToMainView()
        setupConstraints()
        setupBinding()

        PIXEL_PERFECT_screen.createAndSetupInstance(
            baseView: self.view,
            imageName: "PIXEL_PERFECT_home",
            controlsBottomSideOffset: 0,
            imageScaleFactor: 3
        )
    }

    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        
        if isMovingFromParent {
            coordinator?.closeTaskSectionsList()
        }
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(true)

        // TODO: код для разработки (удалить)
        /////////////////////////////////////////////////////
        let vm = viewModel.getTaskListViewModel(forIndexPath: IndexPath(row: 0, section: 1))
        if let vm = vm as? TasksListViewModel {
            coordinator?.selectTaskSection(viewModel: vm)
        }
        /////////////////////////////////////////////////////
    }

    // MARK: action-handlers
    @objc func presentDeleteAlertController(sectionIndexPath: IndexPath) {
        let sectionVM = self.viewModel.getDeletableSectionViewModelFor(
            indexPath: sectionIndexPath
        )
        guard let sectionVM else { return }
        coordinator?.startDeleteProcessSection(sectionVM)
    }
    
}

// MARK: LAYOUT

extension TaskSectionsListViewController {
    private func addSubviewsToMainView() {
        view.addSubview(sectionsTableView)
        view.addSubview(addSectionBottomPanelView)
    }
    
    private func setupControls() {
        view.backgroundColor = .white
        
        sectionsTableView.delegate = self
        sectionsTableView.dataSource = self
        
        addSectionBottomPanelView.delegate = self
    }
    
    private func setupConstraints() {
        NSLayoutConstraint.activate([
            sectionsTableView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            sectionsTableView.bottomAnchor.constraint(equalTo: addSectionBottomPanelView.topAnchor),
            sectionsTableView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor),
            sectionsTableView.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor),
        ])
        
        let bottomPanelHeightConstraint = addSectionBottomPanelView.heightAnchor.constraint(
            equalToConstant: AddSectionBottomPanelView.State.base.params.panelHeight.cgFloat
        )
        addSectionBottomPanelView.panelHeightConstraint = bottomPanelHeightConstraint
        NSLayoutConstraint.activate([
            bottomPanelHeightConstraint,
            addSectionBottomPanelView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            addSectionBottomPanelView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            addSectionBottomPanelView.bottomAnchor.constraint(equalTo: view.keyboardLayoutGuide.topAnchor),
        ])
    }
    
    private func setupBinding() {
        viewModel.bindAndUpdateSections({ [unowned self] sections in
            self.sectionsTableView.reloadData()
        })
    }
}


// MARK: table datasource, delegate
extension TaskSectionsListViewController: UITableViewDataSource, UITableViewDelegate {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return viewModel.getCountOfTableSections()
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return viewModel.getCountTaskSectionsInTableSection(withSectionId: section)
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: TaskSectionTableViewCell.identifier) as! TaskSectionTableViewCell
        
        let sectionCellVM = viewModel.getTaskSectionTableViewCellViewModel(forIndexPath: indexPath)
        
        switch sectionCellVM {
        case let sectionCustomCellVM as SectionCustomListTableViewCellViewModel :
            cell.viewModel = sectionCustomCellVM
            
        case let sectionSystemCellVM as SectionSystemListTableViewCellViewModel:
            cell.viewModel = sectionSystemCellVM
            
        default:
            // TODO: залогировать ошибку
            break
        }
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        viewModel.selectTaskSection(forIndexPath: indexPath) // TODO: нужен ли этот метод?
        
        let taskListInSectionVM = viewModel.getTaskListViewModel(forIndexPath: indexPath)
        guard let taskListInSectionVM else { return }
        
        switch taskListInSectionVM {
        case let taskListInSectionVM as TasksListViewModel :
            coordinator?.selectTaskSection(viewModel: taskListInSectionVM)
            tableView.deselectRow(at: indexPath, animated: true)
            
        default:
            // TODO: проработать открытие системного списка
            print("📋 Открыть системный список")
            
            // TODO: для default залогировать ошибку
            // TODO: nil-вариант
            print("🔴 Залогировать ошибку")
        }
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return TaskSectionTableViewCell.cellHeight
    }
    
    
    // MARK: swipe actions
    func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        let deleteAction = UIContextualAction(style: .destructive, title: "Удалить") { [unowned self] _, _, completionHandler in
            self.presentDeleteAlertController(sectionIndexPath: indexPath)
            completionHandler(true)
        }
        
        let symbolConfig = UIImage.SymbolConfiguration(pointSize: 16, weight: .semibold)
        deleteAction.image = UIImage(systemName: "trash")?
            .withConfiguration(symbolConfig)
        
        let archiveAction = UIContextualAction(style: .normal, title: "Архивировать") { [unowned self] _,_,completionHandler in
            self.viewModel.archiveCustomSection(indexPath: indexPath)
            completionHandler(true)
        }
        archiveAction.image = UIImage(systemName: "archivebox")?
            .withConfiguration(symbolConfig)
        archiveAction.backgroundColor = InterfaceColors.TableCell.orangeSwipeAction
        
        return UISwipeActionsConfiguration(actions: [deleteAction, archiveAction])
    }
    

    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        return UIView()
    }
    
    func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        if section == 0 {
            return TaskSectionsSeparator(frame: .zero)
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


// MARK: add section bottom panel delegate
extension TaskSectionsListViewController: AddSectionBottomPanelViewDelegate {
    func createSectionWith(title: String) {
        viewModel.createCustomTaskSectionWith(title: title)
    }
}


// MARK: coordinator protocol
protocol TaskSectionsListViewControllerCoordinator: AnyObject {
    func selectTaskSection(viewModel: TasksListViewModel)
    
    func startDeleteProcessSection(_ section: TaskSectionDeletableViewModel)
    
    func closeTaskSectionsList()
}
