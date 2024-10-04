
import UIKit

final class TaskDetailCoordinator: BaseCoordinator {

    private var navigation: UINavigationController
    private var viewModel: TaskDetailViewModel
    
    init(
        parent: Coordinator,
        navigation: UINavigationController,
        viewModel: TaskDetailViewModel
    ) {
        self.navigation = navigation
        self.viewModel = viewModel
        super.init(parent: parent)
    }
    
    override func start() {
        let vc = TaskDetailViewController(
            coordinator: self,
            viewModel: viewModel
        )
        navigation.pushViewController(vc, animated: true)
    }
    
    
    // MARK: start of child's coordinators
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
        let vm = viewModel.getTaskReminderCustomDateViewModel()
        
        let coordinator = TaskReminderCustomDateCoordinator(
            parent: self,
            navigation: navigation,
            viewModel: vm,
            delegate: self
        )
        addChild(coordinator)
        coordinator.start()
    }
    
    private func startTaskDeadlineDateVariantsCoordinator() {
        let vm = viewModel.getTaskDeadlineTableVariantsViewModel()
        
        let coordinator = TaskDeadlineDateVariantsCoordinator(
            parent: self,
            navigation: navigation,
            viewModel: vm,
            delegate: self
        )
        addChild(coordinator)
        coordinator.start()
    }
    
    private func startTaskRepeatPeriodVariantsCoordinator() {
        let viewModel = viewModel.getTaskRepeatPeriodTableVariantsViewModel()
        
        let coordinator = TaskRepeatPeriodVariantsCoordinator(
            parent: self,
            navigation: navigation,
            viewModel: viewModel,
            delegate: self
        )
        addChild(coordinator)
        coordinator.start()
    }
    
    private func startAddFileToTaskSourceAlertCoordinator() {
        let coordinator = AddFileToTaskSourceAlertCoordinator(
            parent: self,
            navigation: navigation,
            delegate: self
        )
        addChild(coordinator)
        coordinator.start()
    }
    
    private func startAddFileToTaskFromLibraryCoordinator() {
        let coordinator = AddFileToTaskFromLibraryCoordinator(
            parent: self,
            navigation: navigation,
            delegate: self,
            mode: .library
        )
        addChild(coordinator)
        coordinator.start()
    }
    
    private func startAddFileToTaskFromCameraCoordinator() {
        let coordinator = AddFileToTaskFromLibraryCoordinator(
            parent: self,
            navigation: navigation,
            delegate: self,
            mode: .camera
        )
        addChild(coordinator)
        coordinator.start()
    }
    
    private func startAddFileToTaskFromFilesCoordinator() {
        let coordinator = AddFileToTaskFromFilesCoordinator(
            parent: self,
            navigation: navigation,
            delegate: self
        )
        addChild(coordinator)
        coordinator.start()
    }
    
    private func startTaskDescriptionEditorCoordinator() {
        let viewModel = viewModel.getTaskDescriptionEditorViewModel()
        let coordinator = TaskDescriptionEditorCoordinator(
            parent: self,
            navigation: navigation,
            viewModel: viewModel,
            delegate: self
        )
        addChild(coordinator)
        coordinator.start()
    }
    
    private func startFileDeleteCoordinator(viewModel: TaskFileDeletableViewModel) {
        let coordinator = DeleteItemCoordinator(
            parent: self,
            navigation: navigation,
            viewModels: [viewModel],
            delegate: self
        )
        addChild(coordinator)
        coordinator.start()
    }
    
}

// MARK: - TaskDetailVCCoordinatorDelegate
extension TaskDetailCoordinator: TaskDetailVCCoordinatorDelegate {

    func taskDetailVCReminderDateSetterOpen() {
        if !viewModel.isEnableNotifications {
            startNotificationsDisableAlertCoordinator()
        } else {
            startTaskReminderCustomDateCoordinator()
        }
    }
    
    func taskDetailVCDeadlineDateSetterOpen() {
        startTaskDeadlineDateVariantsCoordinator()
    }
    
    func taskDetailVCRepeatPeriodSetterOpen() {
        startTaskRepeatPeriodVariantsCoordinator()
    }
    
    func taskDetailVCDecriptionEditorOpen() {
        startTaskDescriptionEditorCoordinator()
    }

    func taskDetailVCAddFileStart() {
        startAddFileToTaskSourceAlertCoordinator()
    }

    func taskDetailVCStartDeleteProcessFile(viewModel: TaskFileDeletableViewModel) {
        startFileDeleteCoordinator(viewModel: viewModel)
    }

    func taskDetailVCDidCloseTaskDetail() {
        parent?.removeChild(self)
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
        viewModel.updateTaskField(reminderDateTime: newDate)
    }
}

extension TaskDetailCoordinator: TaskDeadlineDateVariantsCoordinatorDelegate {
    func didChooseTaskDeadlineDate(newDate: Date?) {
        viewModel.updateTaskField(deadlineDate: newDate)
    }
}

extension TaskDetailCoordinator: TaskRepeatPeriodVariantsCoordinatorDelegate {
    func didChooseTaskRepeatPeriod(newPeriod: String?) {
        viewModel.updateTaskField(repeatPeriod: newPeriod)
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
        viewModel.createTaskFile(fromImageData: imageData)
    }
}

extension TaskDetailCoordinator: AddFileToTaskFromFilesCoordinatorDelegate {
    func didFinishPickingFileFromLibrary(withUrl url: URL) {
        viewModel.createTaskFile(fromUrl: url)
    }
}

extension TaskDetailCoordinator: DeleteItemCoordinatorDelegate {
    func didConfirmDeleteItems(_ items: [DeletableItemViewModelType]) {
        if let items = items as? [TaskFileDeletableViewModel] {
            guard let item = items.first else { return }
            viewModel.deleteTaskFile(fileDeletableVM: item)
        } else {
            // удаление задачи
        }
    }
}

extension TaskDetailCoordinator: TaskDescriptionEditorCoordinatorDelegate {
    func didChooseTaskDescription(text: NSAttributedString) {
        viewModel.updateTaskField(descriptionText: text)
    }
}
