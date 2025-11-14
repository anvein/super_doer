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
    private var isEnabledNotifications: Bool { true }

    private var taskReminderDateTimeTemporary: Date?

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

        case .openReminderDateSetter(let dateTime):
            startReminderDateSetter(with: dateTime)

        case .openRepeatPeriodSetter(let repeatPeriod):
            startTaskRepeatPeriodVariants(with: repeatPeriod)

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
            startTaskReminderCustomDateSetter(with: taskReminderDateTimeTemporary)
            taskReminderDateTimeTemporary = nil

        case .didSelectCancel:
            break
        }
    }

    private func handleCustomDateTimeSetterResult(
        _ result: CustomDateSetterCoordinator.FinishResult
    ) {
        switch result {
        case .didDeleteValue:
            viewModel?.coordinatorResult.accept(.didSelectReminderDateTime(nil))

        case .didSelectValue(let dateTime):
            viewModel?.coordinatorResult.accept(.didSelectReminderDateTime(dateTime))
        }
    }

    // MARK: - Childs start

    private func startReminderDateSetter(with dateTime: Date?) {
        if !isEnabledNotifications {
            taskReminderDateTimeTemporary = dateTime
            startNotificationsDisableAlert()
        } else {
            startTaskReminderCustomDateSetter(with: dateTime)
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

    private func startDescriptionEditor(with data: TextEditorData) {
        let coordinator = TextEditorCoordinator(
            parent: self,
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

    private func startTaskReminderCustomDateSetter(with dateTime: Date?) {
        let navCoordinator = NavigationCoordinator(parent: self)
        let dateSetterCoordinator = CustomDateSetterCoordinator(
            parent: navCoordinator,
            mode: .dateAndTime,
            initialValue: dateTime,
            defaultValue: .now.setComponents(hours: 21, minutes: 0, seconds: 0)
        )
        navCoordinator.setTargetCoordinator(dateSetterCoordinator)

        dateSetterCoordinator.finishResult.emit(onNext: { [weak self] result in
            self?.handleCustomDateTimeSetterResult(result)
        })
        .disposed(by: dateSetterCoordinator.disposeBag)

        startChild(navCoordinator) { [weak self] controller in
            self?.rootViewController.present(controller, animated: true)
        }
    }

    private func startTaskRepeatPeriodVariants(with repeatPeriod: TaskRepeatPeriod?) {
        let navCoordinator = NavigationCoordinator(parent: self)
        let targetCoordinator = TaskRepeatPeriodVariantsCoordinator(
            parent: navCoordinator,
            initialValue: repeatPeriod
        )
        navCoordinator.setTargetCoordinator(targetCoordinator)

        targetCoordinator.finishResult.emit(onNext: { [weak self] resultValue in
            self?.viewModel?.coordinatorResult.accept(.didSelectRepeatPeriodValue(resultValue))
        })
        .disposed(by: targetCoordinator.disposeBag)

        startChild(navCoordinator) { [unowned self] navController in
            if let navController = navController as? UINavigationController {
                navController.modalPresentationStyle = .pageSheet
            }

            if let sheet = navController.sheetPresentationController {
                sheet.widthFollowsPreferredContentSizeWhenEdgeAttached = true
                sheet.prefersGrabberVisible = true
                sheet.preferredCornerRadius = 15
            }

            self.rootViewController.present(navController, animated: true)
        }
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
