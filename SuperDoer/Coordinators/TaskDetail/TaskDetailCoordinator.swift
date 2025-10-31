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
            self?.handleTaskDetailViewModel(event)
        }
        .disposed(by: disposeBag)

        let vc = TaskDetailViewController(viewModel: vm)

        viewModel = vm
        viewController = vc
        navigation.delegate = self

        navigation.pushViewController(vc, animated: true)
    }

    private func handleTaskDetailViewModel(_ event: TaskDetailNavigationEvent) {
        switch event {
        case .openDeadlineDateSetter(let deadlineAt):
            startDeadlineDateSetter(deadlineAt: deadlineAt)

        case .openReminderDateSetter:
            startReminderDateSetter()

        case .openRepeatPeriodSetter:
            startRepeatPeriodSetter()

        case .openAddFile:
            startAddFileSourceSelect()

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
            startNotificationsDisableAlertCoordinator()
        } else {
            startTaskReminderCustomDateCoordinator()
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
        startTaskRepeatPeriodVariantsCoordinator()
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
                .didCloseDescriptionEditor(result)
            )
        })
        .disposed(by: coordinator.disposeBag)

        addChild(coordinator)
        coordinator.start()
    }

    func startAddFileSourceSelect() {
        guard let viewController else { return }
        
        let coordinator = AddFileSourceSelectCoordinator(
            parent: self,
            parentController: viewController,
            alertFactory: DIContainer.container.resolve(AddFileSourceAlertFactory.self)!
        )

        coordinator.didCloseResult.emit(onNext: { [weak self] source in
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

    func didCloseTaskDetail() {
        parent?.removeChild(self)
    }

    // MARK: - Result Handlers

    func handleDidSelectAddFileSource(_ source: AddFileSourceAlertFactory.FileSource?) {
        switch source {
        case .camera:
            startAddFileFromCameraCoordinator()

        case .files:
            startAddFileFromFilesCoordinator()

        case .library:
            startAddFileFromLibraryCoordinator()

        default:
            break
        }
    }

    // MARK: - Start childs

    private func startNotificationsDisableAlertCoordinator() {
        guard let viewController else { return }
        let coordinator = NotificationsDisabledAlertCoordinator(
            parent: self,
            parentController: viewController,
            delegate: self
        )

        addChild(coordinator)
        coordinator.start()
    }

    private func startTaskReminderCustomDateCoordinator() {
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

    private func startTaskRepeatPeriodVariantsCoordinator() {
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

    private func startAddFileFromLibraryCoordinator() {
        let coordinator = AddFileToTaskFromLibraryCoordinator(
            parent: self,
            navigation: navigation,
            delegate: self,
            mode: .library
        )
        addChild(coordinator)
        coordinator.start()
    }

    private func startAddFileFromCameraCoordinator() {
        let coordinator = AddFileToTaskFromLibraryCoordinator(
            parent: self,
            navigation: navigation,
            delegate: self,
            mode: .camera
        )
        addChild(coordinator)
        coordinator.start()
    }

    private func startAddFileFromFilesCoordinator() {
        let coordinator = AddFileToTaskFromFilesCoordinator(
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
        startTaskReminderCustomDateCoordinator()
    }

    func didChoosenNotNowEnableNotification() {
        removeChild(withType: NotificationsDisabledAlertCoordinator.self)
        startTaskReminderCustomDateCoordinator()
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

extension TaskDetailCoordinator: AddFileToTaskFromLibraryCoordinatorDelegate {
    func didFinishPickingMediaFromLibrary(imageData: NSData) {
//        viewModel.createTaskFile(fromImageData: imageData)
    }
}

extension TaskDetailCoordinator: AddFileToTaskFromFilesCoordinatorDelegate {
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
