
import UIKit

// MARK: MAIN
/// Контроллер списка задач
class TasksListViewController: UIViewController {
    
    // MARK: controls
    lazy var tasksTable = TaskListTableView(frame: .zero, style: .insetGrouped)
    
    lazy var backgroundImageView = UIImageView(image: UIImage(named: "bgList"))
    
    var largeTitleTextField = UITextField()
    
    var tasksTableDataSource: TasksTableDataSource?
    var tasksTableDelegate: TasksTableDelegate?
    
    
    // MARK: data (tasks)
    var tasksArray: Array<Task> = [
        Task(id: 1, title: "🤩 КВИЗ (18:00)", isCompleted: true),
        Task(id: 2, title: "🏡 Заказать полочку и повесить", isPriority: true),
        Task(id: 3, title: "🏡 Помыть окна"),
        Task(id: 4, title: "🕵️‍♂️ МАФИЯ (19:00)", isCompleted: true),
        Task(id: 5, title: "🏄‍♂️ САП (19 — 21)***"),
        Task(id: 6, title: "⚡️ ПСИХОТЕРАПЕВТ КПТ 29 (16:30, 14 авг)"),
        Task(id: 7, title: "📸 Найти локации для фотосессии", isPriority: true),
        Task(id: 8, title: "🔸 Укол (3к, адв.тмн)", isMyDay: true),
        Task(id: 9, title: "🔹 Задача", isMyDay: false),
        Task(id: 10, title: "🔹 Задача", isMyDay: false),
        Task(id: 11, title: "🔹 Задача", isMyDay: false),
        Task(id: 12, title: "🔹 Задача", isMyDay: false),
    ]
    
    
    // MARK: lyfecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.title = "Задачи на неделю" // TODO: брать из названия конкретного списка
        
//        navigationController?.navigationBar.prefersLargeTitles = true
        navigationItem.largeTitleDisplayMode = .always
//        navigationController?.navigationBar.scrollEdgeAppearance = .
        
//        navigationController?.navigationBar.topItem?.rightBarButtonItem
        navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Edit", style: .plain, target: self, action: #selector(editTable))
        
        
        setupControls()
        addSubviews()
        setupConstraints()
    }
    
    @objc func editTable() {
        tasksTable.isEditing = !tasksTable.isEditing
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        navigationController?.navigationBar.tintColor = InterfaceColors.white
        navigationController?.navigationBar.largeTitleTextAttributes = [
            .foregroundColor: InterfaceColors.white
        ]
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)

        let selectedTask = tasksArray[1]
        let taskController = TaskViewController(task: selectedTask)
        navigationController?.pushViewController(taskController, animated: true)
    }
    
    // MARK: action-handlers
    

}


// MARK: CONTROLS AND LAYOUT SETUP
/// Расширение для инкапсуляции построения макета
extension TasksListViewController {
    // MARK: add subviews and constraints
    private func addSubviews() {
        view.addSubview(tasksTable)
        view.addSubview(backgroundImageView)
    }
    
    private func setupConstraints() {
        // tasksTable
        NSLayoutConstraint.activate([
            tasksTable.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            tasksTable.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor),
            tasksTable.leftAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leftAnchor),
            tasksTable.rightAnchor.constraint(equalTo: view.safeAreaLayoutGuide.rightAnchor),
        ])
        
//        tasksTable.translatesAutoresizingMaskIntoConstraints = false
//        tasksTable.frame = view.bounds
        
    }
    
    // MARK: setup controls
    private func setupControls() {
        setupLayoutController()
        setupTasksTable()
    }
    
    private func setupLayoutController() {
        backgroundImageView.contentMode = .center
        
        backgroundImageView.frame = view.frame
        backgroundImageView.layer.zPosition = 0
        
    }
    
    private func setupTasksTable() {
        tasksTable.layer.zPosition = 10
        tasksTableDataSource = TasksTableDataSource(viewController: self)
        tasksTable.dataSource = tasksTableDataSource
        
        tasksTableDelegate = TasksTableDelegate(viewController: self)
        tasksTable.delegate = tasksTableDelegate
        
        
        
//        tasksTable.setHeaderLabel(self.title)
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
        
        let cell2 = TaskListStandartTaskCell(style: .default, reuseIdentifier: "MyCustomCell")
        let task = viewController.tasksArray[indexPath.row]
        cell2.textLabel?.text = task.title
        
        return cell2
        
        
//        // создание ячейки со стилем
//        let cell = UITableViewCell(style: .subtitle, reuseIdentifier: "MyCellIdentifier")
//
//        let task = viewController.tasksArray[indexPath.row]
//
//        // TODO: переделать на contentConfiguration
//        cell.textLabel?.text = task.title
//        cell.textLabel?.textColor = InterfaceColors.blackText
//
//        cell.detailTextLabel?.text = "Описание"
//        cell.detailTextLabel?.textColor = InterfaceColors.textGray
//
//        if (indexPath.row % 2 == 0) {
//            cell.backgroundColor  = UIColor(white: 0.96, alpha: 1)
//        } else {
//            cell.backgroundColor  = InterfaceColors.lightGray
//        }
//
//        cell.layer.cornerRadius = 15
//        cell.layer.masksToBounds = true
//
//        cell.contentView.layer.cornerRadius = 15
//        cell.contentView.layer.masksToBounds = true
//
//        cell.layer.backgroundColor = InterfaceColors.lightGray.cgColor
//
//        cell.selectedBackgroundView?.backgroundColor = .cyan
//
//
//
//        cell.layer.borderWidth = 1
//        cell.layer.borderColor = UIColor.systemBlue.cgColor
//
//        // nil
//        cell.backgroundView?.layer.cornerRadius = 15
//        cell.backgroundView?.layer.masksToBounds = true
//
////        cell.selectedBackgroundView?.backgroundColor = InterfaceColors.controlsLightBlueBg
//
////        cell.
//
////        cell.accessoryType = task.isCompleted ? .checkmark : .none
//
//        return cell
    }
    
    
    // действие при добавлении или удалении строки
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            // удаление строки из таблицы
            
            viewController.tasksArray.remove(at: indexPath.row)
            tableView.deleteRows(at: [indexPath], with: .fade)
        }
    }

    
    
}

// MARK: table delegate
class TasksTableDelegate: NSObject, UITableViewDelegate {
    let viewController: TasksListViewController
    
    init(viewController: TasksListViewController) {
        self.viewController = viewController
    }
    
    // кликнута строка
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let selectedTask = viewController.tasksArray[indexPath.row]
        
        let taskController = TaskViewController(task: selectedTask)
        viewController.navigationController?.pushViewController(taskController, animated: true)
        
//        tableView.deselectRow(at: indexPath, animated: true)
    }
        
    // возвращает высоту для строк
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 60
    }

    // сделать, чтобы при включении редактирования таблицы (tableView.isEditing) показывался символ редактирования слева (+ / -)
    // но только символ, без функционала
    func tableView(_ tableView: UITableView, editingStyleForRowAt indexPath: IndexPath) -> UITableViewCell.EditingStyle {
        return .delete // or .insert
    }
    
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
//        cell.backgroundColor = .systemPink
//        cell.backgroundView?.backgroundColor = .systemGreen
    }
    
    
    // для реализации кастомного скрытия largeTitle при прокрутке
//    func scrollViewDidScroll(_ scrollView: UIScrollView) {
////        if viewController.tasksTable.contentOffset.y <= 0 {
////            viewController.navigationItem.largeTitleDisplayMode = .always
////        } else {
////            viewController.navigationItem.largeTitleDisplayMode = .never
////        }
////
////        viewController.navigationController?.navigationBar.setNeedsLayout()
////        viewController.view.setNeedsLayout()
////
////        UIView.animate(withDuration: 0.25, animations: {
////            self.viewController.navigationController?.navigationBar.layoutIfNeeded()
////            self.viewController.view.layoutIfNeeded()
////        })
//    }
    
}


// MARK: model
struct Task {
    var id: Int
    
    var title: String?
    var isCompleted: Bool = false
    
    var isMyDay: Bool = false
    
    var isPriority: Bool = false
}
