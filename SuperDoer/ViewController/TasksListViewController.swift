
import UIKit

// MARK: MAIN
/// Контроллер списка задач
class TasksListViewController: UIViewController {
    
    // MARK: controls
    lazy var tasksTable = TasksListTableView(frame: .zero, style: .insetGrouped)
    
    lazy var backgroundImageView = UIImageView(image: UIImage(named: "bgList"))
    
    var largeTitleTextField = UITextField()
    
    
    // MARK: data (tasks)
    var tasksArray: Array<Task> = [
        Task(id: 1, title: "🤩 КВИЗ (18:00)", isCompleted: true),
        Task(
            id: 2,
            title: "🏡 Заказать полочку и повесить",
            isCompleted: true,
            isMyDay: true,
            isPriority: true,
            files: [
                TaskFile(id: 1, name: "marcedes cla.fga", fileExtension: "fga", size: 800),
                TaskFile(id: 2, name: "Видео из файла 13.08.2023, 22:38:33", fileExtension: "mov", size: 1700),
            ],
            description: NSAttributedString(string: "Съездить в леруа\nОтпилить полочки")
        ),
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
    
    // MARK: handlers
    private func deleteTasks(tasksIndexPath: [IndexPath]) {
        for taskIndexPath in tasksIndexPath {
            tasksArray.remove(at: taskIndexPath.row)
        }
        
        tasksTable.deleteRows(at: tasksIndexPath, with: .fade)
    }
    
    private func presentDeleteTaskAlertController(tasksIndexPath: [IndexPath]) {
        var deleteTask: Task? = nil
        if tasksIndexPath.count == 1 {
            deleteTask = tasksArray[tasksIndexPath[0].row]
        }
        
        
        let deleteAlertController = TasksDeleteAlertController(tasksIndexPath: tasksIndexPath, singleTask: deleteTask) { _ in
            self.deleteTasks(tasksIndexPath: tasksIndexPath)
        }
        self.present(deleteAlertController, animated: true)
    }
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
        
        // backgroundImageView
        NSLayoutConstraint.activate([
            backgroundImageView.topAnchor.constraint(equalTo: view.topAnchor),
            backgroundImageView.rightAnchor.constraint(equalTo: view.rightAnchor),
            backgroundImageView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            backgroundImageView.leftAnchor.constraint(equalTo: view.leftAnchor),
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
        backgroundImageView.translatesAutoresizingMaskIntoConstraints = false
        backgroundImageView.contentMode = .scaleAspectFill
        
        backgroundImageView.layer.zPosition = 0
    }
    
    private func setupTasksTable() {
        tasksTable.layer.zPosition = 10
        tasksTable.delegate = self
        tasksTable.dataSource = self
        
//        tasksTable.setHeaderLabel(self.title)
    }
}


// MARK: table delegate + data source
extension TasksListViewController: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return tasksArray.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = TaskListStandartTaskCell(style: .default, reuseIdentifier: "MyCustomCell")
        let task = tasksArray[indexPath.row]
        cell.textLabel?.text = task.title
        
        return cell
    }
    
    
    // MARK: select row
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let selectedTask = tasksArray[indexPath.row]
        
        let taskController = TaskViewController(task: selectedTask)
        navigationController?.pushViewController(taskController, animated: true)
        
//        tableView.deselectRow(at: indexPath, animated: true)
    }
        
    
    // MARK: rows appearance
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
//        cell.backgroundColor = .systemPink
//        cell.backgroundView?.backgroundColor = .systemGreen
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 60
    }

    
    // MARK: swipes actions
    func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        // TODO: доработать, чтобы SwipeAction отображались внутри ячейки (или были со скругленными краями)
        let cell = tableView.cellForRow(at: indexPath)
        guard let cellContentView = cell?.contentView else {
            return nil
        }
        
        let deleteAction = UIContextualAction(style: .destructive, title: "Удалить") { deleteAction, view, completionHandler in
            self.presentDeleteTaskAlertController(tasksIndexPath: [indexPath])
            
            cellContentView.addSubview(view)
            completionHandler(true)
        }
        let symbolConfig = UIImage.SymbolConfiguration(pointSize: 13, weight: .bold)
        deleteAction.image = UIImage(systemName: "trash", withConfiguration: symbolConfig)
        
        return UISwipeActionsConfiguration(actions: [deleteAction])
    }
    
    // добавление действий при свайпах
    func tableView(_ tableView: UITableView, leadingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        let action = UIContextualAction(
            style: .normal,
            title: "☀️") { action, view, completionHandler in
//                self.presentDeleteTaskAlertController(tasksIndexPath: [indexPath])
                print("action")
                
                completionHandler(true)
            }
        action.backgroundColor = .systemOrange
        
        return UISwipeActionsConfiguration(actions: [action])
    }
    
    
    
    // MARK: delete row
    func tableView(_ tableView: UITableView, editingStyleForRowAt indexPath: IndexPath) -> UITableViewCell.EditingStyle {
        if !tableView.isEditing {
            return .delete
        }
        
        return .none
    }
    
//    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
//        if editingStyle == .delete {
//            tasksArray.remove(at: indexPath.row)
//            tableView.deleteRows(at: [indexPath], with: .fade)
//        }
//    }
    
    func tableView(_ tableView: UITableView, shouldIndentWhileEditingRowAt indexPath: IndexPath) -> Bool {
        return false
    }
    
    
    // MARK: move row
    func tableView(_ tableView: UITableView, moveRowAt sourceIndexPath: IndexPath, to destinationIndexPath: IndexPath) {
        let moveElement = tasksArray[sourceIndexPath.row]
        tasksArray[sourceIndexPath.row] = tasksArray[destinationIndexPath.row]
        tasksArray[destinationIndexPath.row] = moveElement
        
        tasksTable.moveRow(at: sourceIndexPath, to: destinationIndexPath)
    }
    
    func tableView(_ tableView: UITableView, canMoveRowAt indexPath: IndexPath) -> Bool {
        return true
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
class Task {
    var id: Int
    
    var title: String?
    var isCompleted: Bool = false
    
    var inMyDay: Bool = false
    
    var isPriority: Bool = false
    
    var reminderDateTime: Date?
    var deadlineDate: Date?
    
    var description: NSAttributedString?
    var descriptionUpdated: Date?
    
    var files: [TaskFile] = []

    init(
        id: Int,
        title: String? = nil,
        isCompleted: Bool = false,
        isMyDay: Bool = false,
        isPriority: Bool = false,
        reminderDateTime: Date? = nil,
        deadlineDate: Date? = nil,
        files: [TaskFile] = [],
        description: NSAttributedString? = nil,
        descriptionUpdated: Date? = nil
    ) {
        self.id = id
        self.title = title
        self.isCompleted = isCompleted
        self.inMyDay = isMyDay
        self.isPriority = isPriority
        self.reminderDateTime = reminderDateTime
        self.deadlineDate = deadlineDate
        self.files = files
        self.description = description
        self.descriptionUpdated = descriptionUpdated
    }
    
    func deleteFile(by id: Int) {
        for (index, file) in files.enumerated() {
            if file.id == id {
                files.remove(at: index)
            }
        }
    }
}

typealias FileSize = Int
class TaskFile {
    var id: Int
    var name: String
    /// kb
    var size: FileSize
    var fileExtension: String
    
    init(id: Int, name: String, fileExtension: String, size: FileSize) {
        self.id = id
        self.name = name
        self.fileExtension = fileExtension
        self.size = size
    }
}
