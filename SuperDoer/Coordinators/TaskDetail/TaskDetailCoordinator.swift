import UIKit
import RxCocoa
import RxRelay
import RxSwift

final class TaskDetailCoordinator: BaseCoordinator {

    private let deleteAlertFactory: DeleteItemsAlertFactory

    private weak var viewModel: (TaskDetailCoordinatorResultHandler & TaskDetailNavigationEmittable)?
    private let viewController: TaskDetailViewController

    override var rootViewController: UIViewController { viewController }

    // TODO: переделать на получение значения из сервиса
    private var isEnableNotifications: Bool { false }

    init(
        parent: Coordinator,
        taskId: UUID,
        deleteAlertFactory: DeleteItemsAlertFactory
    ) {
        let vm = TaskDetailViewModel(
            taskId: taskId,
            taskEm: DIContainer.container.resolve(TaskCoreDataManager.self)!,
            taskFileEm: DIContainer.container.resolve(TaskFileEntityManager.self)!
        )
        self.viewModel = vm
        self.viewController = TaskDetailViewController(viewModel: vm)

        self.deleteAlertFactory = deleteAlertFactory
        super.init(parent: parent)
    }
    
    override func setup() {
        super.setup()

        viewModel?.navigationEvent.emit { [weak self] event in
            self?.handleTaskDetailNavigationEvent(event)
        }
        .disposed(by: disposeBag)
    }

    // MARK: - Actions handlers

    private func handleTaskDetailNavigationEvent(_ event: TaskDetailNavigationEvent) {
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
            startDeleteFileConfirmation(for: viewModel)

        case .openDescriptionEditor(let textEditorData):
            startDescriptionEditor(with: textEditorData)
        }
    }

    private func handleSelectAddFileSource(_ source: ImportFileSource?) {
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

    private func handleNotificationsDisabledAlertResult(
        _ result: NotificationsDisabledAlertCoordinator.FinishResult
    ) {
        switch result {
        case .didSelectNotificationsEnable, .didSelectNotNow:
            startTaskReminderCustomDate()

        case .didSelectCancel:
            break
        }
    }

    // MARK: - Childs start

    private func startReminderDateSetter() {
        if !isEnableNotifications {
            startNotificationsDisableAlert()
        } else {
            startTaskReminderCustomDate()
        }
    }

    private func startDeadlineDateSetter(deadlineAt: Date?) {
        let navCoordinator = NavigationCoordinator(parent: self)
        let targetCoordinator = TaskDeadlineVariantsCoordinator(
            parent: navCoordinator,
            value: deadlineAt
        )
        navCoordinator.setTargetCoordinator(targetCoordinator)

        targetCoordinator.finishResult.emit(onNext: { [weak self] resultValue in
            self?.viewModel?.coordinatorResult.accept(.didSelectDeadlineDate(resultValue))
        })
        .disposed(by: targetCoordinator.disposeBag)

        startChild(navCoordinator) { [weak self] (navigation: UIViewController) in
            navigation.view.backgroundColor = .Common.white
            self?.rootViewController.present(navigation, animated: true)
        }
    }

    private func startRepeatPeriodSetter() {
        startTaskRepeatPeriodVariants()
    }

    private func startDescriptionEditor(with data: TextEditorData) {
        let coordinator = TextEditorCoordinator(
            parent: self,
            parentVC: viewController,
            data: data
        )

        coordinator.finishResult.emit(onNext: { [weak self] result in
            self?.viewModel?.coordinatorResult.accept(
                .didEnteredDescriptionEditorContent(result)
            )
        })
        .disposed(by: coordinator.disposeBag)

        startChild(coordinator) { [weak self] (controller: UIViewController) in
            self?.rootViewController.present(controller, animated: true)
        }
    }

    private func startImportFileSourceSelect() {
        let coordinator = ImportFileSourceSelectCoordinator(
            parent: self,
            alertFactory: DIContainer.container.resolve(ImportFileSourceAlertFactory.self)!
        )

        coordinator.finishResult.emit(onNext: { [weak self] source in
            self?.handleSelectAddFileSource(source)
        })
        .disposed(by: coordinator.disposeBag)

        startChild(coordinator) { [weak self] (alert: UIViewController) in
            self?.rootViewController.present(alert, animated: true)
        }
    }

    private func startDeleteFileConfirmation(for fileDeletable: TaskFileDeletableViewModel) {
        let alert = deleteAlertFactory.makeAlert(fileDeletable) { [weak self] item in
            self?.viewModel?.coordinatorResult.accept(
                .didDeleteTaskFileConfirmed(item)
            )
        } onCancel: { [weak self] in
            self?.viewModel?.coordinatorResult.accept(.didDeleteTaskFileCanceled)
        }

        rootViewController.present(alert, animated: true)
    }

    private func startNotificationsDisableAlert() {
        let coordinator = NotificationsDisabledAlertCoordinator(
            parent: self,
            alertFactory: DIContainer.container.resolve(NotificationsDisabledAlertFactory.self)!
        )

        coordinator.finishResult.emit(onNext: { [weak self] result in
            self?.handleNotificationsDisabledAlertResult(result)
        })
        .disposed(by: coordinator.disposeBag)

        startChild(coordinator) { [weak self] (controller: UIViewController) in
            self?.rootViewController.present(controller, animated: true)
        }
    }

    private func startTaskReminderCustomDate() {
        let alert = UIAlertController(title: "открыть установку напоминания", message: nil, preferredStyle: .alert)
        alert.addAction(.init(title: "ok", style: .cancel))
        rootViewController.present(alert, animated: true)

//        let coordinator = TaskReminderCustomDateCoordinator(
//            parent: self,
//            navigation: navigation,
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

    private func startImportImageFromLibrary(with mode: ImportImageFromLibraryCoordinator.Mode) {
        let coordinator = ImportImageFromLibraryCoordinator(parent: self, mode: mode)

        coordinator.finishResult.emit { [weak self] imageDataResult in
            self?.viewModel?.coordinatorResult.accept(
                .didImportedImage(imageDataResult)
            )
        }
        .disposed(by: coordinator.disposeBag)

        startChild(coordinator) { [weak self] (controller: UIViewController) in
            self?.rootViewController.present(controller, animated: true)
        }
    }

    private func startImportFileFromFiles() {
        let coordinator = ImportFileFromFilesCoordinator(
            parent: self,
            types: [.jpeg, .pdf, .text, .gif]
        )

        coordinator.finishResult.emit { [weak self] fileUrl in
            self?.viewModel?.coordinatorResult.accept(
                .didImportedFile(fileUrl)
            )
        }
        .disposed(by: coordinator.disposeBag)

        startChild(coordinator) { [weak self] (controller: UIViewController) in
            self?.rootViewController.present(controller, animated: true)
        }
    }

}

// MARK: - Delegates of child coordinators

extension TaskDetailCoordinator: TaskReminderCustomDateCoordinatorDelegate {
    func didChooseTaskReminderDate(newDate: Date?) {
//        viewModel.updateTaskField(reminderDateTime: newDate)
    }
}

//extension TaskDetailCoordinator: TaskDeadlineDateVariantsCoordinatorDelegate {
//    func didChooseTaskDeadlineDate(newDate: Date?) {
////        viewModel.updateTaskField(deadlineDate: newDate)
//    }
//}

extension TaskDetailCoordinator: TaskRepeatPeriodVariantsCoordinatorDelegate {
    func didChooseTaskRepeatPeriod(newPeriod: String?) {
//        viewModel.updateTaskField(repeatPeriod: newPeriod)
    }
}
