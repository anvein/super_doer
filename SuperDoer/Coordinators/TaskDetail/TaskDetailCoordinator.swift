import UIKit
import RxCocoa
import RxRelay
import RxSwift

final class TaskDetailCoordinator: BaseCoordinator {

    private let navigation: UINavigationController
    private let taskId: UUID
    private var viewController: TaskDetailViewController?
    private var viewModel: (TaskDetailCoordinatorResultHandler & TaskDetailViewModelOutput)?

    private let disposeBag = DisposeBag()

    init(
        parent: Coordinator,
        navigation: UINavigationController,
        taskId: UUID
    ) {
        self.navigation = navigation
        self.taskId = taskId
        super.init(parent: parent)
    }
    
    override func start() {
        super.start()

        let vm = TaskDetailViewModel(
            taskId: taskId,
            taskEm: DIContainer.container.resolve(TaskCoreDataManager.self)!,
            taskFileEm: DIContainer.container.resolve(TaskFileEntityManager.self)!
        )

        vm.navigationEvent.emit { [weak self] event in
            self?.handleTaskDetailViewModelEvent(event)
        }
        .disposed(by: disposeBag)

        let vc = TaskDetailViewController(viewModel: vm)

        viewModel = vm
        viewController = vc
        navigation.delegate = self

        navigation.pushViewController(vc, animated: true)
    }

    private func handleTaskDetailViewModelEvent(_ event: TaskDetailNavigationEvent) {
        switch event {
        case .openDeadlineDateSetter(let deadlineAt):
            startDeadlineDateSetter(deadlineAt: deadlineAt)

        case .openReminderDateSetter:
            startReminderDateSetter()

        case .openRepeatPeriodSetter:
            startRepeatPeriodSetter()

        case .openAddFile:
            startImportFileSourceSelect()

        case .openDeleteFileConfirmation(viewModel: let viewModel):
            startDeleteFileConfirmation(viewModel: viewModel)

        case .openDescriptionEditor(let textEditorData):
            startDescriptionEditor(with: textEditorData)
        }
    }

}

// MARK: - TaskDetailCoordinatorType

extension TaskDetailCoordinator: TaskDetailCoordinatorType {
    func startReminderDateSetter() {
        guard let viewModel else { return }
        
        if !viewModel.isEnableNotifications {
            startNotificationsDisableAlert()
        } else {
            startTaskReminderCustomDate()
        }
    }
    
    func startDeadlineDateSetter(deadlineAt: Date?) {
        let vm = TaskDeadlineTableVariantsViewModel(
            deadlineDate: deadlineAt
        )

        let coordinator = TaskDeadlineDateVariantsCoordinator(
            parent: self,
            navigation: navigation,
            viewModel: vm,
            delegate: self
        )
        addChild(coordinator)
        coordinator.start()
    }
    
    func startRepeatPeriodSetter() {
        startTaskRepeatPeriodVariants()
    }
    
    func startDescriptionEditor(with data: TextEditorData) {
        guard let viewController else { return }

        let coordinator = TextEditorCoordinator(
            parent: self,
            parentVC: viewController,
            data: data
        )

        coordinator.didFinishWithResultSignal.emit(onNext: { [weak self] result in
            self?.viewModel?.coordinatorResult.accept(
                .didEnteredDescriptionEditorContent(result)
            )
        })
        .disposed(by: coordinator.disposeBag)

        addChild(coordinator)
        coordinator.start()
    }

    func startImportFileSourceSelect() {
        guard let viewController else { return }
        
        let coordinator = ImportFileSourceSelectCoordinator(
            parent: self,
            parentController: viewController,
            alertFactory: DIContainer.container.resolve(ImportFileSourceAlertFactory.self)!
        )

        coordinator.finishResult.emit(onNext: { [weak self] source in
            self?.handleDidSelectAddFileSource(source)
        })
        .disposed(by: coordinator.disposeBag)

        addChild(coordinator)
        coordinator.start()
    }

    func startDeleteFileConfirmation(viewModel: TaskFileDeletableViewModel) {
        //        let coordinator = DeleteItemsConfirmCoordinator(
        //            parent: self,
        //            navigation: navigation,
        //            viewModels: [viewModel],
        //            delegate: self
        //        )
        //        addChild(coordinator)
        //        coordinator.start()
    }

    // MARK: - Result Handlers

    private func handleDidSelectAddFileSource(_ source: ImportFileSourceAlertFactory.FileSource?) {
        switch source {
        case .library:
            startImportImageFromLibrary(with: .library)

        case .camera:
            startImportImageFromLibrary(with: .camera)

        case .files:
            startImportFileFromFiles()

        default:
            break
        }
    }

    // MARK: - Start childs

    private func startNotificationsDisableAlert() {
        guard let viewController else { return }
        let coordinator = NotificationsDisabledAlertCoordinator(
            parent: self,
            parentController: viewController,
            delegate: self
        )

        addChild(coordinator)
        coordinator.start()
    }

    private func startTaskReminderCustomDate() {
//        let vm = viewModel?.getTaskReminderCustomDateViewModel()
//
//        let coordinator = TaskReminderCustomDateCoordinator(
//            parent: self,
//            navigation: navigation,
//            viewModel: vm,
//            delegate: self
//        )
//        addChild(coordinator)
//        coordinator.start()
    }

    private func startTaskRepeatPeriodVariants() {
//        let viewModel = viewModel.getTaskRepeatPeriodTableVariantsViewModel()
//
//        let coordinator = TaskRepeatPeriodVariantsCoordinator(
//            parent: self,
//            navigation: navigation,
//            viewModel: viewModel,
//            delegate: self
//        )
//        addChild(coordinator)
//        coordinator.start()
    }

    private func startImportImageFromLibrary(
        with mode: ImportImageFromLibraryCoordinator.Mode
    ) {
        let coordinator = ImportImageFromLibraryCoordinator(
            parent: self,
            navigation: navigation,
            mode: mode
        )

        coordinator.finishResult.emit { [weak self] imageDataResult in
            self?.viewModel?.coordinatorResult.accept(
                .didImportedImage(imageDataResult)
            )
        }
        .disposed(by: coordinator.disposeBag)

        addChild(coordinator)
        coordinator.start()
    }

    private func startImportFileFromFiles() {
        let coordinator = ImportFileFromFilesCoordinator(
            parent: self,
            navigation: navigation,
            delegate: self
        )
        addChild(coordinator)
        coordinator.start()
    }
}


// MARK: - UINavigationControllerDelegate

extension TaskDetailCoordinator: UINavigationControllerDelegate {
    func navigationController(
        _ navigationController: UINavigationController,
        didShow viewController: UIViewController,
        animated: Bool
    ) {
        guard let selfVC = self.viewController else { return }
        finishIfNavigationPop(selfVC, from: navigation)
    }
}


// MARK: - Delegates of child coordinators

extension TaskDetailCoordinator: NotificationsDisabledAlertCoordinatorDelegate {
    func didChoosenEnableNotifications() {
        removeChild(withType: NotificationsDisabledAlertCoordinator.self)
        startTaskReminderCustomDate()
    }

    func didChoosenNotNowEnableNotification() {
        removeChild(withType: NotificationsDisabledAlertCoordinator.self)
        startTaskReminderCustomDate()
    }
}

extension TaskDetailCoordinator: TaskReminderCustomDateCoordinatorDelegate {
    func didChooseTaskReminderDate(newDate: Date?) {
//        viewModel.updateTaskField(reminderDateTime: newDate)
    }
}

extension TaskDetailCoordinator: TaskDeadlineDateVariantsCoordinatorDelegate {
    func didChooseTaskDeadlineDate(newDate: Date?) {
//        viewModel.updateTaskField(deadlineDate: newDate)
    }
}

extension TaskDetailCoordinator: TaskRepeatPeriodVariantsCoordinatorDelegate {
    func didChooseTaskRepeatPeriod(newPeriod: String?) {
//        viewModel.updateTaskField(repeatPeriod: newPeriod)
    }
}

extension TaskDetailCoordinator: ImportFileFromFilesCoordinatorDelegate {
    func didFinishPickingFileFromLibrary(withUrl url: URL) {
//        viewModel.createTaskFile(fromUrl: url)
    }
}

//extension TaskDetailCoordinator: DeleteItemCoordinatorDelegate {
//    func didConfirmDeleteItems(_ items: [DeletableItemViewModelType]) {
//        if let items = items as? [TaskFileDeletableViewModel] {
//            guard let item = items.first else { return }
//            viewModel.deleteTaskFile(fileDeletableVM: item)
//        } else {
//            // удаление задачи
//        }
//    }
//}
