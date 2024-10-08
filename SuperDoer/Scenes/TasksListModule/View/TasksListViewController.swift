
import UIKit
import SnapKit

/// Контроллер списка задач в отдельном списке (разделе)
class TasksListViewController: UIViewController {

    private var viewModel: TasksListViewModelType
    private weak var coordinator: TaskListViewControllerCoordinator?
    
    // MARK: - Subviews

    private lazy var customView: TasksListVCView = {
        $0.delegate = self
        return $0
    }(TasksListVCView(viewModel: viewModel))

    // MARK: - Init

    init(
        coordinator: TaskListViewControllerCoordinator,
        viewModel: TasksListViewModelType
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
        viewModel.viewDidLoad()

        PIXEL_PERFECT_screen.createAndSetupInstance(
            baseView: self.view,
            imageName: "PIXEL_PERFECT_task_list",
            controlsBottomSideOffset: 0,
            imageScaleFactor: 3
        )
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        navigationController?.navigationBar.tintColor = .Common.white

        if customView.hasTasksInTable {
            customView.reloadTableData()
        }
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)

        // TODO: код для разработки (удалить)
        /////////////////////////////////////////////////////
//        let vm = viewModel.getTaskDetailViewModel(forIndexPath: IndexPath(row: 0, section: 0))
//        if let vm = vm as? TaskDetailViewModel {
//            coordinator?.selectTask(viewModel: vm)
//        }
        /////////////////////////////////////////////////////
    }

    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        
        customView.endEditing(true)

        if isMovingFromParent {
            coordinator?.closeTaskListInSection()
        }
    }
    
}

private extension TasksListViewController {

    // MARK: setup controls

    func setupNavigationBar() {
        self.title = viewModel.taskSectionTitle

        guard let navigationBar = navigationController?.navigationBar else { return }

        navigationBar.tintColor = .white
        navigationBar.titleTextAttributes = [
            .foregroundColor: UIColor.clear,
        ]

        navigationBar.setBackgroundImage(UIImage(), for: .default)
        navigationBar.shadowImage = UIImage()
        navigationBar.isTranslucent = true
        navigationBar.backgroundColor = .clear


//        navigationItem.titleView?.tintColor = .white
//        //        navigationController?.navigationBar.prefersLargeTitles = true
//        navigationItem.largeTitleDisplayMode = .always
//        //        navigationController?.navigationBar.scrollEdgeAppearance = .
//
//        //        navigationController?.navigationBar.topItem?.rightBarButtonItem
//        let editItem = UIBarButtonItem(title: "Edit", style: .plain, target: self, action: #selector(didTapEditTableButton))
//        navigationItem.rightBarButtonItems = [editItem]

        //        navigationController?.navigationBar.setBackgroundImage(UIImage(named: "bgList"), for: UIBarMetrics.compact)
        //        navigationController?.navigationBar.isOpaque = true
    }
}

extension TasksListViewController: TasksListVCViewDelegate {
    func tasksListVCViewNavigationTitleDidChange(isVisible: Bool) {
        guard let navigationBar = navigationController?.navigationBar else { return }
        let titleColor: UIColor = isVisible ? .white : .clear

        UIView.transition(
            with: navigationBar,
            duration: 0.15,
            options: [.transitionCrossDissolve]
        ) { [navigationBar] in
            navigationBar.titleTextAttributes = [.foregroundColor: titleColor]
        }
    }
    
    func tasksListVCViewDidSelectTask(viewModel: TaskDetailViewModel) {
        coordinator?.selectTask(viewModel: viewModel)
    }
    
    func tasksListVCViewDidSelectDeleteTask(tasksIndexPaths: [IndexPath]) {
        let viewModels = viewModel.getTaskDeletableViewModels(forIndexPaths: tasksIndexPaths)
        coordinator?.startDeleteProcessTasks(tasksViewModels: viewModels)
    }

}
