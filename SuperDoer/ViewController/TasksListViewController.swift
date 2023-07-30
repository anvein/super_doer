
import UIKit

// MARK: MAIN
/// Контроллер списка задач
class TasksListViewController: UIViewController {
    
    // MARK: controls
    // создание таблицы
    lazy var tasksTable = UITableView(frame: .zero, style: .insetGrouped)
    
    var tasksTableDataSource: TasksTableDataSource?
    var tasksTableDelegate: TasksTableDelegate?
    
    
    // MARK: data (tasks)
    var tasksArray: Array<Task> = [
        Task(id: 1, title: "🤩 КВИЗ (18:00)", isCompleted: true),
        Task(id: 2, title: "🏡 Заказать полочки и повесить", isPriority: true),
        Task(id: 3, title: "🏡 Помыть окна"),
        Task(id: 4, title: "🕵️‍♂️ МАФИЯ (19:00)", isCompleted: true),
        Task(id: 5, title: "🏄‍♂️ САП (19 — 21)***"),
        Task(id: 6, title: "⚡️ ПСИХОТЕРАПЕВТ КПТ 29 (16:30, 14 авг)"),
        Task(id: 7, title: "📸 Найти локации для фотосессии (написать список)", isPriority: true),
        Task(id: 8, title: "🔸 Укол (3к, адв.тмн)", isMyDay: true),
    ]
    
    
    // MARK: lyfecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.title = "Задачи на неделю" // TODO: брать из названия конкретного списка
        view.backgroundColor = .white
        
        setupLayout()
        addSubviews()
        setupConstraints()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
//        navigationController?.isNavigationBarHidden = true
        navigationController?.navigationBar.prefersLargeTitles = true
        // как отображать title (always = всегда большой, never = всегда маленький)
        // работает, если prefersLargeTitles =  true
//        navigationController?.navigationBar.topItem?.largeTitleDisplayMode = .never
    
        
        
        
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)

    }
    
    // MARK: action-handlers
    @objc func openTaskView() {
        self.navigationController?.pushViewController(
            TaskViewController(task: tasksArray[0]),
            animated: true
        )
    }

}


// MARK: LAYOUT SETUP
/// Расширение для инкапсуляции построения макета
extension TasksListViewController {
    // MARK: add subviews and constraints
    private func addSubviews() {
        view.addSubview(tasksTable)
    }
    
    private func setupConstraints() {
        // tasksTable
        NSLayoutConstraint.activate([
            tasksTable.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            tasksTable.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor),
            tasksTable.leftAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leftAnchor),
            tasksTable.rightAnchor.constraint(equalTo: view.safeAreaLayoutGuide.rightAnchor),
        ])
    }
    
    // MARK: setup controls
    private func setupLayout() {
        setupLayoutController()
        setupTasksTable()
        
        setupTempButtonOpenTaskDetail()
    }
    
    private func setupLayoutController() {
        view.backgroundColor = .white
        
    }
    
    private func setupTasksTable() {
        tasksTable.translatesAutoresizingMaskIntoConstraints = false
        
        tasksTableDataSource = TasksTableDataSource(viewController: self)
        tasksTable.dataSource = tasksTableDataSource
        
        tasksTableDelegate = TasksTableDelegate(viewController: self)
        tasksTable.delegate = tasksTableDelegate
        
        // включено ли редактирование (кнопки минусов в таблице)
        // tasksTable.isEditing = true
        
        
        
        
        
        
        let headerLabel = UILabel()
        headerLabel.text = "Заголовок"
        
        
        tasksTable.tableHeaderView = headerLabel
    
        
    }

    private func setupTempButtonOpenTaskDetail() {
        let btnOpenTasksView = UIButton(type: .system)
        btnOpenTasksView.setTitle("Детальная задачи", for: .normal)
        btnOpenTasksView.translatesAutoresizingMaskIntoConstraints = false
        
        self.view.addSubview(btnOpenTasksView)
        
        NSLayoutConstraint.activate([
            btnOpenTasksView.widthAnchor.constraint(equalToConstant: 220),
            btnOpenTasksView.heightAnchor.constraint(equalToConstant: 45),
            btnOpenTasksView.topAnchor.constraint(equalTo: self.view.topAnchor, constant: 300),
            btnOpenTasksView.centerXAnchor.constraint(equalTo: self.view.centerXAnchor)
        ])
        
        btnOpenTasksView.addTarget(nil, action: #selector(openTaskView), for: .touchUpInside)
    }
    
    
    
    
}


// MARK: table data source
class TasksTableDataSource: NSObject, UITableViewDataSource {
    let viewController: TasksListViewController
    
    init(viewController: TasksListViewController) {
        self.viewController = viewController
    }
    
    // количество строк в разделе
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return viewController.tasksArray.count
    }
    
    // отвечает за внешний вид строки
    // для разных строк можно сделать свой внешний вид
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        // создание ячейки со стилем
        let cell = UITableViewCell(style: .subtitle, reuseIdentifier: "MyCellIdentifier")
        
        
        
        let task = viewController.tasksArray[indexPath.row]
        
        // TODO: переделать на contentConfiguration
        cell.textLabel?.text = task.title
        
        cell.detailTextLabel?.text = "Описание"
        
        cell.backgroundColor = (indexPath.row % 2 == 0)
        ? .white
        : .systemGray5
        
        cell.backgroundView?.layer.cornerRadius = 15
        cell.backgroundView?.layer.masksToBounds = true
        
        print(cell.backgroundColor)
        
//        cell.
        
//        cell.accessoryType = task.isCompleted ? .checkmark : .none
        
        return cell
    }
    
    
    
}

// MARK: table delegate
class TasksTableDelegate: NSObject, UITableViewDelegate {
    let viewController: TasksListViewController
    
    init(viewController: TasksListViewController) {
        self.viewController = viewController
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let selectedTask = viewController.tasksArray[indexPath.row]
        
        let taskController = TaskViewController(
            task: selectedTask
        )
        
        viewController.navigationController?.pushViewController(taskController, animated: true)
    }

}


// MARK: model
struct Task {
    var id: Int
    
    var title: String?
    var isCompleted: Bool = false
    
    var isMyDay: Bool = false
    
    var isPriority: Bool = false
}
