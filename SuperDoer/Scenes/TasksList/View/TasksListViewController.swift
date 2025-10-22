import UIKit
import SnapKit
import RxSwift

class TasksListViewController: UIViewController {

    private let disposeBag = DisposeBag()

    private var viewModel: TasksListViewModelType
    private weak var coordinator: TaskListViewControllerCoordinator?
    
    // MARK: - Subviews

    private lazy var selfView: TasksListVCView = .init()

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
        view = selfView
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        setupView()
        setupBindings()
        setupNavigationBar()
        viewModel.loadInitialData()

//        PIXEL_PERFECT_screen.createAndSetupInstance(
//            baseView: self.view,
//            imageName: "PIXEL_PERFECT_task_list",
//            controlsBottomSideOffset: 0,
//            imageScaleFactor: 3
//        )
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        navigationController?.navigationBar.tintColor = .Common.white

        if selfView.hasTasksInTable {
            selfView.reloadTableData()
        }
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)

//        //  TODO: код для разработки (удалить)
//        ///////////////////////////////////////////////////
//        let vm = viewModel.getTaskDetailViewModel(forIndexPath: IndexPath(row: 0, section: 0))
//        if let vm = vm as? TaskDetailViewModel {
//            coordinator?.selectTask(viewModel: vm)
//        }
//        ///////////////////////////////////////////////////
    }

    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        
        selfView.endEditing(true)

        if isMovingFromParent {
            coordinator?.closeTaskListInSection()
        }
    }
    
}

private extension TasksListViewController {

    // MARK: - Setup

    func setupNavigationBar() {
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

    func setupView() {
        selfView.tableDataSource = self
    }

    func setupBindings() {
        // V -> VM
        selfView.answerSignal.emit(onNext: { [weak self] action in
            self?.handleViewAction(action)
        })
        .disposed(by: disposeBag)

        // VM -> V (VC)
        viewModel.sectionTitleDriver
            .drive(onNext: { [weak self] title in
                self?.title = title
                self?.selfView.setTableHeader(title: title)
            })
            .disposed(by: disposeBag)

        viewModel.sectionTitleDriver
            .drive(selfView.sectionTitleBinder)
            .disposed(by: disposeBag)

            viewModel.tableUpdateEventsSignal
                .emit(onNext: { [weak self] updateEvent in
                    self?.selfView.updateTasksTable(for: updateEvent)
                })
                .disposed(by: disposeBag)
    }

    // MARK: - Actions handlers

    func handleViewAction(_ action: TasksListVCView.Answer) {
        switch action {
        case .onSelectTask(let indexPath):
            guard let detailVM = viewModel.getTaskDetailViewModel(for: indexPath) else { return }
            coordinator?.selectTask(viewModel: detailVM)

        case .onTapIsDoneButton(let indexPath):
            viewModel.switchTaskFieldIsCompletedWith(indexPath: indexPath)

        case .onTapIsPriorityButton(let indexPath):
            viewModel.switchTaskFieldIsPriorityWith(indexPath: indexPath)

        case .onSelectDeleteTasks(let indexPaths):
            let viewModels = viewModel.getTasksDeletableViewModels(for: indexPaths)
            coordinator?.startDeleteProcessTasks(tasksViewModels: viewModels)

        case .onConfirmCreateTask(let taskData):
            viewModel.createNewTaskInCurrentSection(with: taskData)

        case .onNavigationTitleVisibleChange(let isShow):
            updateNavigationBarTitleVisible(isShow: isShow)
        }
    }

    // MARK: - Update view

    func updateNavigationBarTitleVisible(isShow: Bool) {
        guard let navigationBar = navigationController?.navigationBar else { return }
        let titleColor: UIColor = isShow ? .white : .clear

        UIView.transition(
            with: navigationBar,
            duration: 0.15,
            options: [.transitionCrossDissolve]
        ) { [navigationBar] in
            navigationBar.titleTextAttributes = [.foregroundColor: titleColor]
        }
    }

}

// MARK: - TaskListTableDataSource

extension TasksListViewController: TaskListTableDataSource {
    func getSectionsCount() -> Int {
        viewModel.getSectionsCount()
    }

    func getCountRowsInSection(with sectionIndex: Int) -> Int {
        viewModel.getTasksCountInSection(with: sectionIndex)
    }

    func getCellViewModel(for indexPath: IndexPath) -> any TaskTableViewCellViewModelType {
        viewModel.getTasksTableViewCellVM(forIndexPath: indexPath)
    }
}
