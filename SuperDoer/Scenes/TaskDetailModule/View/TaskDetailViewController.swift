
import UIKit
import SnapKit
import RxSwift

class TaskDetailViewController: UIViewController {

    private let viewModel: TaskDetailViewModel
    private weak var coordinator: TaskDetailVCCoordinatorDelegate?

    private let disposeBag = DisposeBag()

    // MARK: - Subviews

    private lazy var readyBarButtonItem = UIBarButtonItem(title: "Готово", style: .done, target: nil, action: nil)

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
        setupBindings()

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
}

private extension TaskDetailViewController {

    // MARK: - Setup

    func setupNavigation() {
        navigationItem.largeTitleDisplayMode = .never
        navigationController?.navigationBar.tintColor = .Text.blue
    }

    func setupBindings() {
        // VM -> V
        viewModel.fieldEditingStateDriver
            .emit(onNext: { [weak self] state in
                self?.handleFieldEditingState(state)
            })
            .disposed(by: disposeBag)

        // V -> VM
        readyBarButtonItem.rx.tap
            .subscribe(onNext:  { [weak self] in
                self?.viewModel.setEditingState(nil)
            })
            .disposed(by: disposeBag)

        // DetailView -> VC
        customView.userAnswerRelay
            .subscribe(onNext: { [weak self] userAnswer in
                self?.handleTaskDetailView(userAnswer)
            })
            .disposed(by: disposeBag)
    }

    // MARK: - Handlers

    func handleFieldEditingState(_ state: TaskDetailViewModel.FieldEditingState?) {
        switch state {
        case .taskTitleEditing, .subtaskAdding, .subtastEditing(_):
            navigationItem.setRightBarButton(readyBarButtonItem, animated: true)
        case nil:
            navigationItem.setRightBarButton(nil, animated: true)
        }
    }

    func handleTaskDetailView(_ userAnswer: TaskDetailView.UserAnswer) {
        switch userAnswer {
        case .deadlineDateSetterOpenDidTap:
            coordinator?.taskDetailVCDeadlineDateSetterOpen()
        case .fileDeleteDidTap(let indexPath):
            startDeleteFileCoordinator(with: indexPath)
        case .repeatPeriodSetterOpenDidTap:
            coordinator?.taskDetailVCRepeatPeriodSetterOpen()
        case .fileAddDidTap:
            coordinator?.taskDetailVCAddFileStart()
        case .reminderDateSetterOpenDidTap:
            coordinator?.taskDetailVCReminderDateSetterOpen()
        case .descriptionEditorOpenDidTap:
            coordinator?.taskDetailVCDecriptionEditorOpen()
        }
    }

    // MARK: - Coordinator methods

    func startDeleteFileCoordinator(with fileCellIndexPath: IndexPath) {
        guard let fileVM = viewModel.getFileDeletableViewModel(for: fileCellIndexPath) else { return }
        coordinator?.taskDetailVCStartDeleteProcessFile(viewModel: fileVM)
    }

}
