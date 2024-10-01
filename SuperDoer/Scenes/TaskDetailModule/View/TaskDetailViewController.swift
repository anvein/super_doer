
import UIKit
import SnapKit

class TaskDetailViewController: UIViewController {

    private var viewModel: TaskDetailViewModel
    private weak var coordinator: TaskDetailVCCoordinatorDelegate?

    // MARK: - Subviews

    private lazy var customView: TaskDetailView = .init(viewModel: viewModel)

    // MARK: - Init

    init(
        coordinator: TaskDetailVCCoordinatorDelegate,
        viewModel: TaskDetailViewModel
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
        
        setupNavigation()

        PIXEL_PERFECT_screen.createAndSetupInstance(
            baseView: self.view,
            imageName: "PIXEL_PERFECT_detail1",
            controlsBottomSideOffset: 0,
            imageScaleFactor: 3
        )
    }

    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        
        if isMovingFromParent {
            coordinator?.taskDetailVCDidCloseTaskDetail()
        }
    }
    
    // MARK: - Actions handlers


    @objc func showTaskTitleNavigationItemReady() {
        let rightBarButonItem = UIBarButtonItem(
            title: "Готово",
            style: .done,
            target: self,
            action: #selector(pressedTaskTitleNavigationItemReady)
        )
        
        navigationController?.navigationBar.topItem?.setRightBarButton(rightBarButonItem, animated: true)
    }
    
    @objc func pressedTaskTitleNavigationItemReady() {
        navigationItem.setRightBarButton(nil, animated: true)
        customView.taskTitleTextView.resignFirstResponder()
    }
    
    @objc func showSubtaskAddNavigationItemReady() {
        let rightBarButonItem = UIBarButtonItem(
            title: "Готово",
            style: .done,
            target: self,
            action: #selector(pressedSubtaskAddNavigationItemReady)
        )
        
        navigationItem.setRightBarButton(rightBarButonItem, animated: true)
    }
    
    @objc func pressedSubtaskAddNavigationItemReady() {
        // TODO: переделать на endEdit
        customView.textFieldEditing?.resignFirstResponder()
        navigationItem.setRightBarButton(nil, animated: true)
    }
    
    
    // MARK: coordinator methods
    private func startDeleteFileCoordinatorFor(_ fileCellIndexPath: IndexPath) {
        guard let fileVM = viewModel.getFileDeletableViewModelFor(fileCellIndexPath) else { return }
        coordinator?.taskDetailVCStartDeleteProcessFile(viewModel: fileVM)
    }

}

private extension TaskDetailViewController {

    // MARK: - Setup

    func setupNavigation() {
        navigationItem.largeTitleDisplayMode = .never
        navigationController?.navigationBar.tintColor = .Text.blue
    }
}
