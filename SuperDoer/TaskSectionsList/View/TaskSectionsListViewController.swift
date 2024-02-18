
import UIKit
import CoreData

/// Экран списков (разделов)
class TaskSectionsListViewController: UIViewController {

    lazy var sectionsTableView = TaskSectionsTableView()
    
    lazy var addSectionBottomPanelView = AddSectionBottomPanelView()
    
    
    
    
    var viewModel: TaskSectionsListViewModel?

    
    
    // MARK: life cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        title = "Списки"
        
        navigationController?.navigationBar.prefersLargeTitles = true
        navigationItem.largeTitleDisplayMode = .never
        
        viewModel?.sectionsUpdateClosure = { [unowned self] in
            self.sectionsTableView.reloadData()
        }
        
        setupControls()
        addSubviewsToMainView()
        setupConstraints()
        
        
        #if DEBUG
            PixelPerfectScreen.getInstanceAndSetup(
                baseView: view,
                imageName: "screen4",
                topAnchorConstant: 0,
                controlsBottomAnchorConstant: -60
            )
        #endif
    }
    
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(true)
        
//        let vc = TasksListViewController(section: sections[1].first as! TaskSection)
//        navigationController?.pushViewController(vc, animated: false)
    }
    
    
    
    // MARK: action-handlers
    
    
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
        
        let bottomPanelHeightConstraint = addSectionBottomPanelView.heightAnchor.constraint(equalToConstant: 48)
        addSectionBottomPanelView.panelHeightConstraint = bottomPanelHeightConstraint
        NSLayoutConstraint.activate([
            bottomPanelHeightConstraint,
            addSectionBottomPanelView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            addSectionBottomPanelView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            addSectionBottomPanelView.bottomAnchor.constraint(equalTo: view.keyboardLayoutGuide.topAnchor),
        ])
        
    }
    
}


// MARK: table datasource, delegate
extension TaskSectionsListViewController: UITableViewDataSource, UITableViewDelegate {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return viewModel?.getCountOfTableSections() ?? 0
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return viewModel?.getTaskSectionsCountInTableSection(withSectionId: section) ?? 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: TaskSectionTableViewCell.identifier) as! TaskSectionTableViewCell
        
        let sectionCellViewModel = viewModel?.getTaskSectionTableViewCellViewModel(forIndexPath: indexPath)
        
        switch sectionCellViewModel {
        case let sectionCustomCellViewModel as TaskSectionCustomTableViewCellViewModel :
            cell.viewModel = sectionCustomCellViewModel
            
        case let sectionSystemCellViewModel as TaskSectionSystemTableViewCellViewModel:
            cell.viewModel = sectionSystemCellViewModel
            
        default:
            // TODO: залогировать ошибку
            break
        }
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        guard let viewModel = viewModel else { return }
        
        viewModel.selectTaskSection(forIndexPath: indexPath)
        
        let taskSectionCellViewModel = viewModel.getViewModelForSelectedRow()
        
        switch taskSectionCellViewModel {
        case let sectionCustomCellViewModel as TaskSectionCustomTableViewCellViewModel :
            // TODO: переделать на view-model
            
            let tasksSectionViewModel = TasksInSectionViewModel(taskSection: sectionCustomCellViewModel.getTaskSection() as! TaskSectionCustom)

            let tasksInSectionVc = TasksInSectionViewController(viewModel: tasksSectionViewModel)
            navigationController?.pushViewController(tasksInSectionVc, animated: true)
            
            
            tableView.deselectRow(at: indexPath, animated: true)
            
        case let sectionSystemCellViewModel as TaskSectionSystemTableViewCellViewModel:
            print("📋 Открыть системный список")
            
        default:
            // TODO: залогировать ошибку
            // TODO: nil-вариант
            print("🔴 Залогировать ошибку")
        }
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 48.4
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



