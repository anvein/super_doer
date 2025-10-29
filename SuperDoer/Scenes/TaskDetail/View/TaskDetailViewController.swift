import UIKit
import RxSwift

class TaskDetailViewController: UIViewController {

    private let viewModel: TaskDetailViewModel

    private let disposeBag = DisposeBag()

    // MARK: - Subviews

    private lazy var readyBarButtonItem = UIBarButtonItem(title: "Готово", style: .done, target: nil, action: nil)
    private lazy var customView = TaskDetailView(viewModel: viewModel)

    // MARK: - Init

    init(viewModel: TaskDetailViewModel) {
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
        viewModel.loadInitialData()

//        PIXEL_PERFECT_screen.createAndSetupInstance(
//            baseView: self.view,
//            imageName: "PIXEL_PERFECT_detail1",
//            controlsBottomSideOffset: 0,
//            imageScaleFactor: 3
//        )
    }
}

private extension TaskDetailViewController {

    // MARK: - Setup

    func setupNavigation() {
        navigationItem.largeTitleDisplayMode = .never
        navigationController?.navigationBar.tintColor = .Text.blue
    }

    func setupBindings() {
        // V / VC -> V
        viewModel.fieldEditingStateDriver
            .distinctUntilChanged()
            .emit(onNext: { [weak self] state in
                self?.handleFieldEditingState(state)
            })
            .disposed(by: disposeBag)

        // V / VC -> VM
        readyBarButtonItem.rx.tap
            .subscribe(onNext:  { [weak self] in
                self?.viewModel.setEditingState(nil)
            })
            .disposed(by: disposeBag)

        // V -> VC
        customView.answerSignal
            .emit(onNext: { [weak self] userAnswer in
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

    func handleTaskDetailView(_ userAnswer: TaskDetailView.Answer) {
        switch userAnswer {
        case .didTapOpenDeadlineDateSetter:
            viewModel.didTapOpenDeadlineDateSetter()
            
        case .didTapFileDelete(let indexPath):
            startDeleteFileCoordinator(with: indexPath)
        case .didTapOpenRepeatPeriodSetter:
            break
//            coordinator?.taskDetailVCRepeatPeriodSetterOpen()
        case .didTapAddFile:
            break
//            coordinator?.taskDetailVCAddFileStart()
        case .didTapOpenReminderDateSetter:
            break
//            coordinator?.taskDetailVCReminderDateSetterOpen()

        case .didTapOpenDescriptionEditor:
            viewModel.didTapOpenDescriptionEditor()
        }
    }

    // MARK: - Coordinator methods

    func startDeleteFileCoordinator(with fileCellIndexPath: IndexPath) {
        guard let fileVM = viewModel.getFileDeletableViewModel(for: fileCellIndexPath) else { return }
//        coordinator?.taskDetailVCStartDeleteProcessFile(viewModel: fileVM)
    }

}
