
import UIKit
import SnapKit

/// Контроллер списка задач в отдельном списке (разделе)
class TasksListInSectionViewController: UIViewController {
    
    private var viewModel: TasksListInSectionViewModelType
    private weak var coordinator: TaskListInSectionViewControllerCoordinator?
    
    // MARK: - Subviews

    private lazy var customView: TaskListInSectionVCView = {
        $0.delegate = self
        return $0
    }(TaskListInSectionVCView(viewModel: viewModel))

    // MARK: - Init

    init(
        coordinator: TaskListInSectionViewControllerCoordinator,
        viewModel: TasksListInSectionViewModelType
    ) {
        self.coordinator = coordinator
        self.viewModel = viewModel
        
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - Lifecycle

    override func loadView() {
        view = customView
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        setupNavigationBar()

        PIXEL_PERFECT_screen.createAndSetupInstance(
            baseView: self.view,
            imageName: "PIXEL_PERFECT_task_list",
            controlsBottomSideOffset: 0,
            imageScaleFactor: 3
        )
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        navigationController?.navigationBar.tintColor = InterfaceColors.white
        navigationController?.navigationBar.largeTitleTextAttributes = [
            .foregroundColor: InterfaceColors.white
        ]
        
        if customView.tasksTableView.numberOfRows(inSection: 0) > 0 {
            customView.tasksTableView.reloadData()
        }
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)

        // TODO: код для разработки (удалить)
        /////////////////////////////////////////////////////
//        let vm = viewModel.getTaskViewModel(forIndexPath: IndexPath(row: 0, section: 0))
//        if let vm = vm as? TaskDetailViewModel {
//            coordinator?.selectTask(viewModel: vm)
//        }
        /////////////////////////////////////////////////////
    }

    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        
        if isMovingFromParent {
            coordinator?.closeTaskListInSection()
        }
    }
    
    // MARK: - Actions handlers

    @objc func didTapEditTableButton() {
        customView.tasksTableView.isEditing.toggle()
    }
    
}

private extension TasksListInSectionViewController {

    // MARK: setup controls

    func setupNavigationBar() {
        self.title = viewModel.taskSectionTitle

        //        navigationController?.navigationBar.prefersLargeTitles = true
        navigationItem.largeTitleDisplayMode = .always
        //        navigationController?.navigationBar.scrollEdgeAppearance = .

        //        navigationController?.navigationBar.topItem?.rightBarButtonItem
        let editItem = UIBarButtonItem(title: "Edit", style: .plain, target: self, action: #selector(didTapEditTableButton))
        navigationItem.rightBarButtonItems = [editItem]

        //        navigationController?.navigationBar.setBackgroundImage(UIImage(named: "bgList"), for: UIBarMetrics.compact)
        //        navigationController?.navigationBar.isOpaque = true
    }
}

extension TasksListInSectionViewController: TaskListInSectionVCViewDelegate {
    func taskListInSectionVCViewDidSelectTask(viewModel: TaskDetailViewModel) {
        coordinator?.selectTask(viewModel: viewModel)
    }
    
    func taskListInSectionVCViewDidSelectDeleteTask(tasksIndexPaths: [IndexPath]) {
        let viewModels = viewModel.getTaskDeletableViewModels(forIndexPaths: tasksIndexPaths)
        coordinator?.startDeleteProcessTasks(tasksViewModels: viewModels)
    }

}
