import UIKit
import RxCocoa
import RxRelay
import RxSwift

final class TaskDetailCoordinator: BaseCoordinator {

    private let navigation: UINavigationController
    private let taskId: UUID
    private weak var viewController: TaskDetailViewController?

    private let viewModelEventsRelay = PublishRelay<TaskDetailCoordinatorVmEvent>()

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
        let vm = TaskDetailViewModel(
            taskId: taskId,
            coodinator: self,
            taskEm: DIContainer.container.resolve(TaskCoreDataManager.self)!,
            taskFileEm: DIContainer.container.resolve(TaskFileEntityManager.self)!
        )
        let vc = TaskDetailViewController(viewModel: vm)
        viewController = vc
        navigation.delegate = self

        navigation.pushViewController(vc, animated: true)
    }

}

// MARK: - TaskDetailCoordinatorType

extension TaskDetailCoordinator: TaskDetailCoordinatorType {
    var viewModelEventSignal: Signal<TaskDetailCoordinatorVmEvent> {
        viewModelEventsRelay.asSignal()
    }

    func startReminderDateSetter() {
//        if !viewModel.isEnableNotifications {
//            startNotificationsDisableAlertCoordinator()
//        } else {
//            startTaskReminderCustomDateCoordinator()
//        }
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
    
    func startDecriptionEditor(with data: TextEditorData) {
        guard let viewController else { return }

        let coordinator = TextEditorCoordinator(
            parent: self,
            parentVC: viewController,
            data: data
        )

        coordinator.didCloseEventSignal.emit(onNext: { [weak self] result in
            self?.viewModelEventsRelay.accept(
                .didCloseDescriptionEditor(result)
            )
        })
        .disposed(by: coordinator.externalDiposeBag)

        addChild(coordinator)
        coordinator.start()
    }

    func startAddFile() {
        startAddFileToTaskSourceAlertCoordinator()
    }

    func startDeleteFileConfirmation(viewModel: TaskFileDeletableViewModel) {
        startFileDeleteCoordinator(viewModel: viewModel)
    }

    func didCloseTaskDetail() {
        parent?.removeChild(self)
    }

    // MARK: - Start childs

    private func startNotificationsDisableAlertCoordinator() {
        let coordinator = NotificationsDisabledAlertCoordinator(
            parent: self,
            navigation: navigation,
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

    private func startAddFileToTaskSourceAlertCoordinator() {
//        let coordinator = AddFileToTaskSourceAlertCoordinator(
//            parent: self,
//            navigation: navigation,
//            delegate: self
//        )
//        addChild(coordinator)
//        coordinator.start()
    }

    private func startAddFileToTaskFromLibraryCoordinator() {
//        let coordinator = AddFileToTaskFromLibraryCoordinator(
//            parent: self,
//            navigation: navigation,
//            delegate: self,
//            mode: .library
//        )
//        addChild(coordinator)
//        coordinator.start()
    }

    private func startAddFileToTaskFromCameraCoordinator() {
//        let coordinator = AddFileToTaskFromLibraryCoordinator(
//            parent: self,
//            navigation: navigation,
//            delegate: self,
//            mode: .camera
//        )
//        addChild(coordinator)
//        coordinator.start()
    }

    private func startAddFileToTaskFromFilesCoordinator() {
//        let coordinator = AddFileToTaskFromFilesCoordinator(
//            parent: self,
//            navigation: navigation,
//            delegate: self
//        )
//        addChild(coordinator)
//        coordinator.start()
    }

    private func startFileDeleteCoordinator(viewModel: TaskFileDeletableViewModel) {
//        let coordinator = DeleteItemsConfirmCoordinator(
//            parent: self,
//            navigation: navigation,
//            viewModels: [viewModel],
//            delegate: self
//        )
//        addChild(coordinator)
//        coordinator.start()
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

extension TaskDetailCoordinator: AddFileToTaskSourceAlertCoordinatorDelegate {
    func didChooseSourceForAddFile(_ source: SourceForAddingFile) {
        switch source {
        case .library:
            startAddFileToTaskFromLibraryCoordinator()
            
        case .camera:
            startAddFileToTaskFromCameraCoordinator()
        
        case .files:
            startAddFileToTaskFromFilesCoordinator()
        }
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
