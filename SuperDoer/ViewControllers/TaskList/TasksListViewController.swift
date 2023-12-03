
import UIKit
import CoreData

// MARK: MAIN
/// Контроллер списка задач
class TasksListViewController: UIViewController {

    // TODO: переделать на DI-контейнер
    lazy var taskEm = TaskEntityManager()
    
    
    // MARK: controls
    lazy var tasksTable = TasksListTableView(frame: .zero, style: .insetGrouped)
    
    lazy var backgroundImageView = UIImageView(image: UIImage(named: "bgList"))
    
    
    // MARK: data (tasks)
    var tasks = [Task]()
    
    var taskList: TaskListCustom
    
    init(taskList: TaskListCustom) {
        self.taskList = taskList
        
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: lyfecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.title = "Задачи на неделю" // TODO: брать из названия конкретного списка
        
//        navigationController?.navigationBar.prefersLargeTitles = true
        navigationItem.largeTitleDisplayMode = .always
//        navigationController?.navigationBar.scrollEdgeAppearance = .
        
//        navigationController?.navigationBar.topItem?.rightBarButtonItem
        let editItem = UIBarButtonItem(title: "Edit", style: .plain, target: self, action: #selector(editTable))
        let addItem = UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(showAddTaskAlertController))
        
        navigationItem.rightBarButtonItems = [addItem, editItem]
        
//        navigationController?.navigationBar.setBackgroundImage(UIImage(named: "bgList"), for: UIBarMetrics.compact)
//        navigationController?.navigationBar.isOpaque = true
        
        setupControls()
        addSubviews()
        setupConstraints()
    }
    

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        navigationController?.navigationBar.tintColor = InterfaceColors.white
        navigationController?.navigationBar.largeTitleTextAttributes = [
            .foregroundColor: InterfaceColors.white
        ]
        
        let taskList = taskList as? TaskListCustom
        tasks = taskEm.getTasks(for: taskList)
        if tasksTable.numberOfRows(inSection: 0) > 0 {
            tasksTable.reloadData()
        }
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(true)
        
//        let task = tasks[0] as! Task
//        let vc = TaskViewController(task: task)
//        navigationController?.pushViewController(vc, animated: false)
    }
    
    
    // MARK: handlers
    @objc func editTable() {
        tasksTable.isEditing = !tasksTable.isEditing
    }
    
    @objc private func showAddTaskAlertController() {
        let alertController = UIAlertController(title: "Add task", message: "Enter task title", preferredStyle: .alert)

        alertController.addTextField() { taskTitleTf in
            taskTitleTf.placeholder = "Title"
        }
        
        let saveAction = UIAlertAction(title: "Save", style: .default) { action in
            guard let taskTitle = alertController.textFields?.first?.text else {
               return
            }

            self.saveNewTask(taskTitle: taskTitle)
        }
        
        let cancelAction = UIAlertAction(title: "Cancel", style: .destructive)
        
        alertController.addAction(cancelAction)
        alertController.addAction(saveAction)
        
        present(alertController, animated: true)
    }
    
    @objc private func saveNewTask(taskTitle: String) {
        let task = taskEm.createWith(title: taskTitle, section: taskList)
        
        tasks.insert(task, at: 0)
        tasksTable.reloadData()
    }
    
    private func presentDeleteTaskAlertController(tasksIndexPath: [IndexPath]) {
        var deleteTask: Task? = nil
        if tasksIndexPath.count == 1 {
            deleteTask = tasks[tasksIndexPath[0].row]
        }
        
        let deleteAlertController = TasksDeleteAlertController(tasksIndexPath: tasksIndexPath, singleTask: deleteTask) { _ in
            self.deleteTasks(tasksIndexPaths: tasksIndexPath)
        }
        self.present(deleteAlertController, animated: true)
    }
    
    private func deleteTasks(tasksIndexPaths: [IndexPath]) {
        var deleteTasksArray = [Task]()
        
        for taskIndexPath in tasksIndexPaths {
            deleteTasksArray.append(tasks[taskIndexPath.row])
            tasks.remove(at: taskIndexPath.row)
        }
        
        tasksTable.deleteRows(at: tasksIndexPaths, with: .fade)
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
    }
    
    // MARK: setup controls
    private func setupControls() {
        setupLayoutController()
        setupTasksTable()
    }
    
    private func setupLayoutController() {
        backgroundImageView.translatesAutoresizingMaskIntoConstraints = false
        backgroundImageView.contentMode = .scaleAspectFill
        backgroundImageView.clipsToBounds = true
        
        backgroundImageView.layer.zPosition = 0
    }
    
    private func setupTasksTable() {
        tasksTable.layer.zPosition = 10
        tasksTable.delegate = self
        tasksTable.dataSource = self
        
//        tasksTable.insertSubview(refreshControl, at: 0)
        
//        tasksTable.setHeaderLabel(self.title)
    }
}


// MARK: table delegate + data source
extension TasksListViewController: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return tasks.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = TaskListStandartTaskCell(style: .default, reuseIdentifier: "MyCustomCell")
    
        let taskMO = tasks[indexPath.row]
        cell.textLabel?.text = taskMO.title
        
        return cell
    }
    
    
    // MARK: select row
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let selectedTask = tasks[indexPath.row]
        
        let taskController = TaskViewController(task: selectedTask)
        navigationController?.pushViewController(taskController, animated: true)
        
        tableView.deselectRow(at: indexPath, animated: true)
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
        guard let _ = cell?.contentView else {
            return nil
        }
        
        let deleteAction = UIContextualAction(style: .destructive, title: "Удалить") { deleteAction, view, completionHandler in
            self.presentDeleteTaskAlertController(tasksIndexPath: [indexPath])
            
//            cellContentView.addSubview(view)
            completionHandler(false)
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
                print("☀️ add to my day")
                
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
        let moveElement = tasks[sourceIndexPath.row]
        tasks[sourceIndexPath.row] = tasks[destinationIndexPath.row]
        tasks[destinationIndexPath.row] = moveElement
        
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
