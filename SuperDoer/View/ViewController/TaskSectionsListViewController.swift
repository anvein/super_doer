
import UIKit
import CoreData

/// Экран списков (разделов)
class TaskSectionsListViewController: UIViewController {

    private lazy var sectionsTableView = TaskSectionsTableView()
    
    private lazy var addSectionBottomPanelView = AddSectionBottomPanelView()
    
    var viewModel: TaskSectionListViewModelType?

    
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
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(true)
      
//        guard let vm = viewModel?.getTaskListInSectionViewModel(forIndexPath: IndexPath(row: 0, section: 1)) else { return }
//        let vc = TaskListInSectionViewController(viewModel: vm)
//        navigationController?.pushViewController(vc, animated: false)
    }
    
    
    // MARK: action-handlers
    @objc func presentDeleteAlertController(sectionsIndexPaths: [IndexPath]) {
        let deleteAlertController = DeleteAlertController(itemsIndexPath: sectionsIndexPaths, singleItem: nil) { [unowned self] _ in
            self.viewModel?.deleteSections(withIndexPaths: sectionsIndexPaths)
        } 
        deleteAlertController.itemTypeName = DeletableItem.ItemTypeName(
            oneIP: "список",
            oneVP: "список",
            manyVP: "списки"
        )
        self.present(deleteAlertController, animated: true)
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
        viewModel?.bindAndUpdateSections({ [unowned self] sections in
            self.sectionsTableView.reloadData()
        })
    }
}


// MARK: table datasource, delegate
extension TaskSectionsListViewController: UITableViewDataSource, UITableViewDelegate {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return viewModel?.getCountOfTableSections() ?? 0
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return viewModel?.getCountTaskSectionsInTableSection(withSectionId: section) ?? 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: TaskSectionTableViewCell.identifier) as! TaskSectionTableViewCell
        
        let sectionCellViewModel = viewModel?.getTaskSectionTableViewCellViewModel(forIndexPath: indexPath)
        
        switch sectionCellViewModel {
        case let sectionCustomCellViewModel as TaskSectionCustomListTableViewCellViewModel :
            cell.viewModel = sectionCustomCellViewModel
            
        case let sectionSystemCellViewModel as TaskSectionSystemListTableViewCellViewModel:
            cell.viewModel = sectionSystemCellViewModel
            
        default:
            // TODO: залогировать ошибку
            break
        }
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        guard let viewModel = viewModel else { return }
        
        viewModel.selectTaskSection(forIndexPath: indexPath) // TODO: нужен ли этот метод?
        
        let taskListInSectionViewModel = viewModel.getTaskListInSectionViewModel(forIndexPath: indexPath)
        guard let taskListInSectionViewModel else { return }
        
        switch taskListInSectionViewModel {
        case let taskListInSectionViewModel as TaskListInSectionViewModel :
            let tasksInSectionVc = TaskListInSectionViewController(viewModel: taskListInSectionViewModel)
            navigationController?.pushViewController(tasksInSectionVc, animated: true)
            
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
            self.presentDeleteAlertController(sectionsIndexPaths: [indexPath])
            completionHandler(true)
        }
        
        let symbolConfig = UIImage.SymbolConfiguration(pointSize: 16, weight: .semibold)
        deleteAction.image = UIImage(systemName: "trash")?
            .withConfiguration(symbolConfig)
        
        let archiveAction = UIContextualAction(style: .normal, title: "Архивировать") { [unowned self] _,_,completionHandler in
            self.viewModel?.archiveCustomSection(indexPath: indexPath)
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
        viewModel?.createCustomTaskSectionWith(title: title)
    }
}


@available(iOS 17, *)
#Preview(traits: .defaultLayout, body: {
//    var lists: [[TaskSectionProtocol]] = [[],[]]
//    lists[0] = SystemListBuilder().buildLists()
//    lists[1] = TaskSectionEntityManager().getCustomListsWithOrder()
//    
//    let taskListsViewModel = TaskSectionsListViewModel(sections: lists)
//    let taskListsViewController = TaskSectionsListViewController()
//    taskListsViewController.viewModel = taskListsViewModel
//
//    let navigationController = UINavigationController(rootViewController: taskListsViewController)
    
    return TaskSectionsListViewController()
})



