
import UIKit
import CoreData

/// Экран списков
class TaskSectionsViewController: UIViewController, UIScrollViewDelegate {

    lazy var sectionEm = TaskSectionEntityManager()
    
    lazy var systemSectionBuilder = SystemSectionBuilder()
    
    var sectionsTableView = TaskSectionsTableView(frame: .zero, style: .grouped)
        
        
    var sections: [[Any]] = [
        [],
        [],
    ]

    
    // MARK: life cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        title = "Списки"
        
        navigationController?.navigationBar.prefersLargeTitles = true
        navigationItem.largeTitleDisplayMode = .never
        navigationItem.rightBarButtonItems = [
            UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(showAddSectionAlertController))
        ]
        
        setupControls()
        addSubviewsToMainView()
        setupConstraints()
        
        PixelPerfectScreen.getInstanceAndSetup(baseView: view, imageName: "screen_home", topAnchorConstant: -11)  // TODO: удалить временный код (perfect pixel screen)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        sections[0] = systemSectionBuilder.buildSections()
        sections[1] = sectionEm.getCustomSectionsWithOrder()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(true)
        
        let vc = TasksListViewController(section: sections[1].first as! TaskSection)
        navigationController?.pushViewController(vc, animated: false)
    }
    
    
    
    // MARK: action-handlers
    @objc private func showAddSectionAlertController() {
        let alert = UIAlertController(title: "Новый список", message: nil, preferredStyle: .alert)
        
        alert.addTextField { textField in
            textField.placeholder = "Название списка"
        }
        
        alert.addAction(
            UIAlertAction(title: "Отмена", style: .destructive)
        )
        
        alert.addAction(
            UIAlertAction(title: "Добавить", style: .default, handler: { action in
                if let sectionTitle = alert.textFields?.first?.text {
                    let section = self.sectionEm.createCustomSectionWith(title: sectionTitle)
                    self.sections[1].insert(section, at: 0)
                    
                    self.sectionsTableView.reloadData()
                }
            })
        )
        
        present(alert, animated: true)
    }
 
    
    // MARK: other methods
}


// MARK: LAYOUT
extension TaskSectionsViewController {
    private func addSubviewsToMainView() {
        view.addSubview(sectionsTableView)
    }
    
    private func setupControls() {
        view.backgroundColor = .white
//        sectionsTableView.backgroundColor = .systemBlue
        
        sectionsTableView.delegate = self
        sectionsTableView.dataSource = self
    }
    
    private func setupConstraints() {
        NSLayoutConstraint.activate([
            sectionsTableView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            sectionsTableView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor),
            sectionsTableView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor),
            sectionsTableView.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor),
        ])
    }
    
}


// MARK: table datasource, delegate
extension TaskSectionsViewController: UITableViewDataSource, UITableViewDelegate {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return sections.count
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return sections[section].count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        // TODO: зарегистрировать ячейку
        let cell = tableView.dequeueReusableCell(withIdentifier: TaskSectionTableViewCell.identifier) as! TaskSectionTableViewCell
        
        switch sections[indexPath.section][indexPath.row] {
        case let customSection as TaskSection :
            cell.fillFrom(taskSection: customSection)
            
        case let systemSection as SystemSection:
            cell.fillFrom(systemSection: systemSection)
            
        default:
            // TODO: залогировать ошибку
            break
        }
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let section = sections[indexPath.section][indexPath.row]
        
        if let sectionCustom = section as? TaskSection {
            let taskListVc = TasksListViewController(section: sectionCustom)
            navigationController?.pushViewController(taskListVc, animated: true)
            
            tableView.deselectRow(at: indexPath, animated: true)
        } else if section is String {
            
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

