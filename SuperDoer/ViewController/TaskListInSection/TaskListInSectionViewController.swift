
import UIKit
import CoreData

/// Контроллер списка задач в отдельном списке (разделе)
class TaskListInSectionViewController: UIViewController {
    
    private var viewModel: TaskListInSectionViewModelType
    private weak var coordinator: TaskListInSectionViewControllerCoordinator?
    
    
    // MARK: controls
    private lazy var tasksTable = TasksListTableView()
    private lazy var createTaskPanelView = CreateTaskBottomPanelView()
    
    private lazy var backgroundImageView = UIImageView(image: UIImage(named: "bgList"))
    
    
    // MARK: init
    init(
        coordinator: TaskListInSectionViewControllerCoordinator,
        viewModel: TaskListInSectionViewModelType
    ) {
        self.coordinator = coordinator
        self.viewModel = viewModel
        
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
    // MARK: lyfecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.title = viewModel.taskSectionTitle
        
        //        navigationController?.navigationBar.prefersLargeTitles = true
        navigationItem.largeTitleDisplayMode = .always
        //        navigationController?.navigationBar.scrollEdgeAppearance = .
        
        //        navigationController?.navigationBar.topItem?.rightBarButtonItem
        let editItem = UIBarButtonItem(title: "Edit", style: .plain, target: self, action: #selector(editTable))
        navigationItem.rightBarButtonItems = [editItem]
        
        //        navigationController?.navigationBar.setBackgroundImage(UIImage(named: "bgList"), for: UIBarMetrics.compact)
        //        navigationController?.navigationBar.isOpaque = true
        
        setupControls()
        addSubviews()
        setupConstraints()
        
        if let viewModel = viewModel as? TaskListInSectionViewModel {
            viewModel.tasksUpdateBinding = { [unowned self] in
                // TODO: реализовать красивое удаление/перемещение/добавление задач из таблицы
                // tasksTable.deleteRows(at: tasksIndexPaths, with: .fade)
                // tasksTable.moveRow(at: sourceIndexPath, to: destinationIndexPath)
                self.tasksTable.reloadData()
            }
        }

        PIXEL_PERFECT_screen.createAndSetupInstance(
            baseView: self.view,
            imageName: "PIXEL_PERFECT_task_list",
            imageAttachSide: .top,
            imageAttachSideOffset: 0,
            controlsBottomSideOffset: 0,
            imageHeightDivider: 3
        )
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        navigationController?.navigationBar.tintColor = InterfaceColors.white
        navigationController?.navigationBar.largeTitleTextAttributes = [
            .foregroundColor: InterfaceColors.white
        ]
        
        if tasksTable.numberOfRows(inSection: 0) > 0 {
            tasksTable.reloadData()
        }
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        
        if isMovingFromParent {
            coordinator?.closeTaskListInSection()
        }
    }
    
    
    // MARK: handlers
    @objc func editTable() {
        tasksTable.isEditing = !tasksTable.isEditing
    }
    
    private func presentDeleteTaskAlertController(taskIndexPaths: [IndexPath]) {
        let viewModels = self.viewModel.getTaskDeletableViewModels(
            forIndexPaths: taskIndexPaths
        )
        coordinator?.startDeleteProcessTasks(tasksViewModels: viewModels)
    }
    
}


// MARK: CONTROLS AND LAYOUT SETUP
/// Расширение для инкапсуляции построения макета
extension TaskListInSectionViewController {
    // MARK: add subviews and constraints
    private func addSubviews() {
        view.addSubview(tasksTable)
        view.addSubview(backgroundImageView)
        view.addSubview(createTaskPanelView)
    }
    
    private func setupConstraints() {
        // tasksTable
        NSLayoutConstraint.activate([
            tasksTable.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
//            tasksTable.bottomAnchor.constraint(equalTo: createTaskPanelView.topAnchor, constant: -8),
            tasksTable.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 8),
            tasksTable.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -8),
        ])
        
        // backgroundImageView
        NSLayoutConstraint.activate([
            backgroundImageView.topAnchor.constraint(equalTo: view.topAnchor),
            backgroundImageView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            backgroundImageView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            backgroundImageView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
        ])
        
        // addSectionBottomPanelView
        let panelHeightConstraint = createTaskPanelView.heightAnchor.constraint(
            equalToConstant: CreateTaskBottomPanelView.State.base.params.panelHeight.cgFloat
        )
        let panelLeadingConstraint = createTaskPanelView.leadingAnchor.constraint(
            equalTo: view.leadingAnchor,
            constant: CreateTaskBottomPanelView.State.base.params.panelSidesConstraintConstant.cgFloat
        )
        let panelTrailingConstraint = createTaskPanelView.trailingAnchor.constraint(
            equalTo: view.trailingAnchor,
            constant: -CreateTaskBottomPanelView.State.base.params.panelSidesConstraintConstant.cgFloat
        )
        let panelTopConstraint = createTaskPanelView.topAnchor.constraint(
            equalTo: tasksTable.bottomAnchor,
            constant: CreateTaskBottomPanelView.State.base.params.panelTopConstraintConstant.cgFloat
        )
        
        createTaskPanelView.panelHeightConstraint = panelHeightConstraint
        createTaskPanelView.panelLeadingAnchorConstraint = panelLeadingConstraint
        createTaskPanelView.panelTrailingAnchorConstraint = panelTrailingConstraint
        createTaskPanelView.panelTopAnchorConstraint = panelTopConstraint
        
        NSLayoutConstraint.activate([
            panelHeightConstraint,
            panelLeadingConstraint,
            panelTrailingConstraint,
            panelTopConstraint,
            createTaskPanelView.bottomAnchor.constraint(equalTo: view.keyboardLayoutGuide.topAnchor),
        ])
    }
    
    // MARK: setup controls
    private func setupControls() {
        setupLayoutController()
        setupTasksTable()
        
        createTaskPanelView.delegate = self
    }
    
    private func setupLayoutController() {
        backgroundImageView.translatesAutoresizingMaskIntoConstraints = false
        backgroundImageView.contentMode = .scaleAspectFill
        backgroundImageView.clipsToBounds = true
        
        backgroundImageView.layer.zPosition = 0
    }
    
    private func setupTasksTable() {
        tasksTable.layer.zPosition = 1
        tasksTable.delegate = self
        tasksTable.dataSource = self
        
//        tasksTable.insertSubview(refreshControl, at: 0)
        
//        tasksTable.setHeaderLabel(self.title)
    }
}


// MARK: table delegate + data source
extension TaskListInSectionViewController: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return viewModel.getTasksCount()
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: StandartTaskTableViewCell.identifier) as! StandartTaskTableViewCell
        let taskCellViewModel = viewModel.getTaskInSectionTableViewCellViewModel(forIndexPath: indexPath)
        
        cell.textLabel?.text = taskCellViewModel.title
        cell.detailTextLabel?.text = taskCellViewModel.sectionTitle
        cell.isDoneButton.isOn = taskCellViewModel.isCompleted
        
        return cell
    }
    
    
    // MARK: select row
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let selectedTaskVM = viewModel.getTaskViewModel(forIndexPath: indexPath)
        coordinator?.selectTask(viewModel: selectedTaskVM)
        
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
        
        let deleteAction = UIContextualAction(
            style: .destructive,
            title: "Удалить"
        ) { [weak self] _, _, completionHandler in
            self?.presentDeleteTaskAlertController(taskIndexPaths: [indexPath])
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
        viewModel.moveTasksInCurrentList(fromPath: sourceIndexPath, to: destinationIndexPath)
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

extension TaskListInSectionViewController: CreateTaskBottomPanelViewDelegate {
    func createTaskWith(title: String, inMyDay: Bool, reminderDateTime: Date?, deadlineAt: Date?, description: String?) {
       // TODO: удалить пробелы по краям
        
        let result = title.trimmingCharacters(in: .whitespacesAndNewlines)
        if !result.isEmpty {
            viewModel.createNewTaskInCurrentSectionWith(
                title: title,
                inMyDay: inMyDay,
                reminderDateTime: reminderDateTime,
                deadlineAt: deadlineAt,
                description: description
            )
        }
    }
}


// MARK: - coordinator protocol
protocol TaskListInSectionViewControllerCoordinator: AnyObject {
    func selectTask(viewModel: TaskDetailViewModel)
    
    func startDeleteProcessTasks(tasksViewModels: [TaskDeletableViewModel])
    
    func closeTaskListInSection()
}
