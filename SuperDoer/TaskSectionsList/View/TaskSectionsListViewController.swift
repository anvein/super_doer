
import UIKit
import CoreData

/// Экран списков
class TaskSectionsListViewController: UIViewController, UIScrollViewDelegate {

    var listsTableView = TaskSectionsTableView()
        
    var viewModel: TaskSectionsViewModelType?

    
    // MARK: life cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        title = "Списки"
        
        navigationController?.navigationBar.prefersLargeTitles = true
        navigationItem.largeTitleDisplayMode = .never
        navigationItem.rightBarButtonItems = [
            UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(showAddListAlertController))
        ]
        
        setupControls()
        addSubviewsToMainView()
        setupConstraints()
        
        PixelPerfectScreen.getInstanceAndSetup(baseView: view, imageName: "screen_home", topAnchorConstant: -11)  // TODO: удалить временный код (perfect pixel screen)
    }
    
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(true)
        
//        let vc = TasksListViewController(section: sections[1].first as! TaskSection)
//        navigationController?.pushViewController(vc, animated: false)
    }
    
    
    
    // MARK: action-handlers
    @objc private func showAddListAlertController() {
        let alert = UIAlertController(title: "Новый список", message: nil, preferredStyle: .alert)
        
        alert.addTextField { textField in
            textField.placeholder = "Название списка"
        }
        
        alert.addAction(
            UIAlertAction(title: "Отмена", style: .destructive)
        )
        
        alert.addAction(
            UIAlertAction(title: "Добавить", style: .default, handler: { action in
                if let listTitle = alert.textFields?.first?.text {
                    self.viewModel?.createCustomTaskSectionWith(title: listTitle)
                    self.listsTableView.reloadData() // TODO: точно юзать reloadData()?
                }
            })
        )
        
        present(alert, animated: true)
    }
}


// MARK: LAYOUT
extension TaskSectionsListViewController {
    private func addSubviewsToMainView() {
        view.addSubview(listsTableView)
    }
    
    private func setupControls() {
        view.backgroundColor = .white
        
        listsTableView.delegate = self
        listsTableView.dataSource = self
    }
    
    private func setupConstraints() {
        NSLayoutConstraint.activate([
            listsTableView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            listsTableView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor),
            listsTableView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor),
            listsTableView.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor),
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
        // TODO: зарегистрировать ячейку
        let cell = tableView.dequeueReusableCell(withIdentifier: TaskSectionTableViewCell.identifier) as! TaskSectionTableViewCell
        
        let taskListCellViewModel = viewModel?.getTaskSectionTableViewCellViewModel(forIndexPath: indexPath)
        
        switch taskListCellViewModel {
        case let listCustomCellViewModel as TaskSectionCustomTableViewCellViewModel :
            cell.viewModel = listCustomCellViewModel
            
        case let listSystemCellViewModel as TaskSectionSystemTableViewCellViewModel:
            cell.viewModel = listSystemCellViewModel
            
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
            
            let tasksListViewModel = TasksInSectionViewModel(taskSection: sectionCustomCellViewModel.getTaskSection() as! TaskSectionCustom)

            let tasksInSectionVc = TasksInSectionViewController(viewModel: tasksListViewModel)
            navigationController?.pushViewController(tasksInSectionVc, animated: true)
            
            
            tableView.deselectRow(at: indexPath, animated: true)
            
        case let listSystemCellViewModel as TaskSectionSystemTableViewCellViewModel:
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

