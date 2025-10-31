import UIKit
import RxSwift

class TaskDetailViewController: UIViewController {

    private let viewModel: TaskDetailViewModelInput & TaskDetailViewModelOutput

    private let disposeBag = DisposeBag()

    // MARK: - Subviews

    private let readyBarButtonItem = UIBarButtonItem(title: "Готово", style: .done, target: nil, action: nil)
    private let selfView: TaskDetailView

    // MARK: - Init

    init(viewModel: TaskDetailViewModelInput & TaskDetailViewModelOutput) {
        self.viewModel = viewModel
        self.selfView = TaskDetailView(viewModel: viewModel)

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

        setupNavigation()
        setupBindings()
        viewModel.inputEvent.accept(.needLoadInitialData)

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
        // VM -> VC
        viewModel.fieldEditingStateDriver
            .distinctUntilChanged()
            .drive(onNext: { [weak self] state in
                self?.handleFieldEditingState(state)
            })
            .disposed(by: disposeBag)

        // V / VC -> VM
        readyBarButtonItem.rx.tap
            .map { .didTapTextEditingReadyBarButton }
            .bind(to: viewModel.inputEvent)
            .disposed(by: disposeBag)
    }

    // MARK: - Handlers

    func handleFieldEditingState(_ state: TaskDetailViewModelFieldEditingState?) {
        switch state {
        case .taskTitleEditing, .subtaskAdding, .subtastEditing(_):
            navigationItem.setRightBarButton(readyBarButtonItem, animated: true)
        case nil:
            navigationItem.setRightBarButton(nil, animated: true)
        }
    }

    // MARK: - Coordinator methods

    func startDeleteFileCoordinator(with fileCellIndexPath: IndexPath) {
//        guard let fileVM = viewModel.getFileDeletableViewModel(for: fileCellIndexPath) else { return }
//        coordinator?.taskDetailVCStartDeleteProcessFile(viewModel: fileVM)
    }

}
