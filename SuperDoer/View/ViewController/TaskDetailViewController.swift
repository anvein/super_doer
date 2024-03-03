
import UIKit

/// Контроллер просмотра / редактирования задачи
// MARK: MAIN
class TaskDetailViewController: UIViewController {
    enum FieldNameIdentifier: String {
        case taskDeadline
        case taskRepeatPeriod
        case taskReminderDate
    }
    
    // MARK: controls
    private lazy var taskDoneButton = CheckboxButton()
    private lazy var taskTitleTextView = UITaskTitleTextView()
    private lazy var isPriorityButton = StarButton()
    
    private lazy var taskDataTableView = TaskDetailTableView()
    
    /// Редактируемое в данный момент поле TextField
    private var textFieldEditing: UITextField?
    
    
    // MARK: view model
    private var viewModel: TaskDetailViewModel
    
    
    // MARK: init
    init(viewModel: TaskDetailViewModel) {
        self.viewModel = viewModel
        
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
    // MARK: life cycle methods
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupControls()
        addSubviews()
        setupConstraints()
        setupBindings()
        
         //PixelPerfectScreen.getInstanceAndSetup(baseView: view)  // TODO: удалить временный код (perfect pixel screen)
    }

    
    // MARK: controller action-handlers
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
        taskTitleTextView.resignFirstResponder()
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
        textFieldEditing?.resignFirstResponder()
        navigationItem.setRightBarButton(nil, animated: true)
    }
    
    
    // MARK: coordinator methods
    private func presentSettingsTaskReminder() {
        // TODO: сделать проверку включены ли уведомления для приложения (+ вынести в VM + сервис)
        let isEnableNotifications = true
        if !isEnableNotifications {
            let notificationDisableAlert = NotificationDisabledAlertController()
            notificationDisableAlert.delegate = self
            
            present(notificationDisableAlert, animated: true)
        } else {
            presentTaskReminderCustomDateController()
        }
    }
    
    private func presentTaskReminderCustomDateController() {
        let vm = viewModel.getTaskReminderCustomDateViewModel()
        let vc = CustomDateSetterViewController(
            viewModel: vm,
            identifier: FieldNameIdentifier.taskReminderDate.rawValue,
            datePickerMode: .dateAndTime
        )
        vc.delegate = self
        vc.title = "Напоминание"
        
        present(vc, animated: true)
    }
    
    private func presentTaskDeadlineTableVariantsController() {
        let vm = viewModel.getTaskDeadlineTableVariantsViewModel()
        
        let deadlineVariantsController = TableVariantsViewController(
            viewModel: vm,
            identifier: FieldNameIdentifier.taskDeadline.rawValue
        )
        deadlineVariantsController.delegate = self
        deadlineVariantsController.title = "Срок"
        let navigationController = UINavigationController(rootViewController: deadlineVariantsController)
        
        present(navigationController, animated: true)
    }
    
    private func presentTaskRepeatPeriodTableVariantsController() {
        let vm = viewModel.getTaskRepeatPeriodTableVariantsViewModel()
        
        let variantsController = TableVariantsViewController(
            viewModel: vm,
            identifier: FieldNameIdentifier.taskRepeatPeriod.rawValue
        )
        variantsController.delegate = self
        variantsController.title = "Повтор"
        let navigationController = UINavigationController(rootViewController: variantsController)
        
        present(navigationController, animated: true)
    }
    
    private func presentDeleteFileAlertController(fileCellIndexPath indexPath: IndexPath) {
        let fileCellVM = viewModel.getFileCellViewModel(forIndexPath: indexPath)
        guard let fileCellVM else { return }
        
        let deleteAlert = DeleteAlertController(
            itemsIndexPath: [indexPath],
            singleItem: fileCellVM) { indexPaths in
            self.viewModel.deleteTaskFile(fileCellIndexPath: indexPath)
        }
        deleteAlert.itemTypeName = (oneIP: "файл", oneVP: "файл", manyVP: "файлы")
        
        present(deleteAlert, animated: true)
    }
    
    private func presentAddFileAlertController() {
        let alertController = AddFileSourceAlertController()
        alertController.delegate = self
        present(alertController, animated: true)
    }
    
    private func presentDescriptionController() {
        let vm = viewModel.getTaskDescriptionEditorViewModel()
        let vc = TextEditorViewController(viewModel: vm)
        vc.dismissDelegate = self
        
        present(vc, animated: true)
    }
    
    
    // MARK: other methods
    private func buildTableViewCellFor(_ cellViewModel: TaskDataCellViewModelType) -> UITableViewCell {
        let cell: UITableViewCell
        
        switch cellViewModel {
        case _ as AddSubTaskCellViewModel:
            cell = taskDataTableView.dequeueReusableCell(withIdentifier: AddSubtaskButtonCell.identifier)!
            if let cell = cell as? AddSubtaskButtonCell {
                cell.subtaskTextField.delegate = self
            }
            
        case let cellVM as AddToMyDayCellViewModel:
            cell = taskDataTableView.dequeueReusableCell(withIdentifier: AddToMyDayButtonCell.identifier)!
            if let cell = cell as? AddToMyDayButtonCell {
                cell.isOn = cellVM.inMyDay
                cell.delegate = self
            }
        
        case let cellVM as ReminderDateCellViewModel:
            cell = taskDataTableView.dequeueReusableCell(withIdentifier: ReminderDateButtonCell.identifier)!
            if let cell = cell as? ReminderDateButtonCell {
                cell.fillFrom(cellVM)
                cell.delegate = self
            }
            
        case let cellVM as DeadlineDateCellViewModel:
            cell = taskDataTableView.dequeueReusableCell(withIdentifier: DeadlineDateButtonCell.identifier)!
            if let cell = cell as? DeadlineDateButtonCell {
                cell.fillFrom(cellVM)
                cell.delegate = self
            }
            
        case let cellVM as RepeatPeriodCellViewModel:
            cell = taskDataTableView.dequeueReusableCell(withIdentifier: RepeatPeriodButtonCell.identifier)!
            if let cell = cell as? RepeatPeriodButtonCell {
                cell.fillFrom(cellVM)
                cell.delegate = self
            }
            
        case _ as AddFileCellVeiwModel:
            cell = taskDataTableView.dequeueReusableCell(withIdentifier: AddFileButtonCell.identifier)!
        
        case let cellVM as FileCellViewModel:
            cell = taskDataTableView.dequeueReusableCell(withIdentifier: FileButtonCell.identifier)!
            if let cell = cell as? FileButtonCell {
                cell.delegate = self
                cell.fillFrom(cellValue: cellVM)
            }
            
        case let cellVM as DescriptionCellViewModel:
            cell = taskDataTableView.dequeueReusableCell(withIdentifier: DescriptionButtonCell.identifier)!
            if let cell = cell as? DescriptionButtonCell {
                cell.delegate = self
                cell.fillFrom(cellVM)
            }
            
        default :
            cell = taskDataTableView.dequeueReusableCell(withIdentifier: TaskDetailLabelsButtonCell.identifier)!
            // TODO: залогировать
        }
        
        return cell
    }
    
}

/// Расширение для инкапсуляции настройки контролов и макета
// MARK: SETUP LAYOUT
extension TaskDetailViewController {
    
    // MARK: add subviews & constraints
    private func addSubviews() {
        view.addSubview(taskDoneButton)
        view.addSubview(taskTitleTextView)
        view.addSubview(isPriorityButton)

        view.addSubview(taskDataTableView)
    }
    
    private func setupConstraints() {
        // taskDoneButton
        NSLayoutConstraint.activate([
            taskDoneButton.topAnchor.constraint(equalTo: taskTitleTextView.topAnchor, constant: 9),
            taskDoneButton.leftAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leftAnchor, constant: 19),
        ])
        
        // taskTitleTextView
        NSLayoutConstraint.activate([
            taskTitleTextView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 18),
            taskTitleTextView.leftAnchor.constraint(equalTo: taskDoneButton.rightAnchor, constant: 14),
            taskTitleTextView.rightAnchor.constraint(equalTo: isPriorityButton.leftAnchor, constant: -5),
            taskTitleTextView.heightAnchor.constraint(greaterThanOrEqualToConstant: 45)
        ])
        
        // isPriorityButton
        NSLayoutConstraint.activate([
            isPriorityButton.centerXAnchor.constraint(equalTo: view.safeAreaLayoutGuide.rightAnchor, constant: -27),
            isPriorityButton.centerYAnchor.constraint(equalTo: taskTitleTextView.topAnchor, constant: 21),
        ])
        
        // taskDataTableView
        NSLayoutConstraint.activate([
            taskDataTableView.topAnchor.constraint(equalTo: taskTitleTextView.bottomAnchor),
            taskDataTableView.leftAnchor.constraint(equalTo: view.leftAnchor),
            taskDataTableView.rightAnchor.constraint(equalTo: view.rightAnchor),
            taskDataTableView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            taskDataTableView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
        ])
    }
    
    // MARK: setup controls methods
    private func setupControls() {
        // view of controller
        view.backgroundColor = InterfaceColors.white
        
        // navigationItem
        navigationItem.largeTitleDisplayMode = .never
        navigationController?.navigationBar.tintColor = InterfaceColors.textBlue
        
        // taskTitleTextView, taskDoneButton, isPriorityButton
        taskTitleTextView.delegate = self
        taskDoneButton.delegate = self
        isPriorityButton.delegate = self
        
        // taskDataTableView
        taskDataTableView.dataSource = self
        taskDataTableView.delegate = self
    }
    
    private func setupBindings() {
        viewModel.taskTitle.bindAndUpdateValue { [unowned self] title in
            taskTitleTextView.text = title
        }
        
        viewModel.taskIsCompleted.bindAndUpdateValue { [unowned self] isCompleted in
            taskDoneButton.isOn = isCompleted
        }
        
        viewModel.taskIsPriority.bindAndUpdateValue { [unowned self] isPriority in
            isPriorityButton.isOn = isPriority
        }
        
        viewModel.bindingDelegate = self
    }
}


// MARK: table delegate and dataSource
extension TaskDetailViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return viewModel.countTaskDataCellsValues
    }
    
    
    // MARK: cell appearance
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cellVM = viewModel.getTaskDataCellViewModelFor(indexPath: indexPath)
        
        return buildTableViewCellFor(cellVM)
    }
    
    
    // MARK: select row
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let cell = tableView.cellForRow(at: indexPath)
        
        switch cell {
        case let addSubtaskButton as AddSubtaskButtonCell :
            addSubtaskButton.subtaskTextField.becomeFirstResponder()
        
        case _ as AddToMyDayButtonCell :
            viewModel.switchValueTaskFieldInMyDay()
            
        case _ as ReminderDateButtonCell :
            presentSettingsTaskReminder()
            
        case _ as DeadlineDateButtonCell :
            presentTaskDeadlineTableVariantsController()
            
        case _ as RepeatPeriodButtonCell :
            presentTaskRepeatPeriodTableVariantsController()
            
        case _ as AddFileButtonCell :
            presentAddFileAlertController()
            
        case _ as FileButtonCell :
            print("💎 Открылся контроллер и показать содержимое файла")
            
        case _ as DescriptionButtonCell:
            presentDescriptionController()
            
        default :
            break
        }
        
        tableView.deselectRow(at: indexPath, animated: false)
    }
    
    
    // MARK: swipes for row
    func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        let deleteAction = UIContextualAction(
            style: .destructive,
            title: "Удалить"
        ) { deleteAction, view, completionHandler in
            self.presentDeleteFileAlertController(fileCellIndexPath: indexPath)
            
            completionHandler(true)
        }
        let symbolConfig = UIImage.SymbolConfiguration(pointSize: 14, weight: .bold)
        deleteAction.image = UIImage(systemName: "trash", withConfiguration: symbolConfig)
        
        return UISwipeActionsConfiguration(actions: [deleteAction])
    }

    
    // MARK: "edit" / delete row
    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        if viewModel.isFileCellViewModel(byIndexPath: indexPath) {
            return true
        }
        
        return false
    }

    func tableView(_ tableView: UITableView, editingStyleForRowAt indexPath: IndexPath) -> UITableViewCell.EditingStyle {
        return .none
    }
    
    func tableView(_ tableView: UITableView, shouldIndentWhileEditingRowAt indexPath: IndexPath) -> Bool {
        return false
    }

}


// MARK: task title TextView delegate
extension TaskDetailViewController: UITextViewDelegate {
    func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
        if (text == "\n") {
            navigationController?.navigationBar.topItem?.setRightBarButton(nil, animated: true)
            textView.resignFirstResponder()
            
            return false
        } else {
            return true
        }
    }
    
    func textViewDidBeginEditing(_ textView: UITextView) {
        showTaskTitleNavigationItemReady()
    }
    
    func textViewDidEndEditing(_ textView: UITextView) {
        viewModel.updateTaskField(title: textView.text)
    }

    // TODO: заменять перевод строки на пробел когда заканчивается редактирование названия
}


// MARK: subtask TextField delegate
extension TaskDetailViewController: UITextFieldDelegate {
    func textFieldDidBeginEditing(_ textField: UITextField) {
        // TODO: определять верный ли textField
        showSubtaskAddNavigationItemReady()
        textFieldEditing = textField
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        // TODO: определять верный ли textField
        if textFieldEditing === textField {
            textField.resignFirstResponder()
            navigationItem.setRightBarButton(nil, animated: true)
            textFieldEditing = nil
        }
        
        return false
    }
}


// MARK: cell delegates, child controllers delegates
/// Протокол связанный с чекбоксом "Задача выполнена"
extension TaskDetailViewController: CheckboxButtonDelegate {
    func checkboxDidChangeValue(newValue: Bool) {
        viewModel.updateTaskField(isCompleted: newValue)
    }
}

/// Протокол связанный с полем "Приоритет"
extension TaskDetailViewController: StarButtonDelegate {
    func starButtonValueDidChange(newValue: Bool) {
        viewModel.updateTaskField(isPriority: newValue)
    }
}

/// Делегат связанный с полем "Дата напоминания"
extension TaskDetailViewController: NotificationsDisabledAlertControllerDelegate {
    func didChoosenEnableNotifications() {
        print("🎚️ Открыть настройки уведомлений")
        
        presentTaskReminderCustomDateController()
    }
    
    func didChoosenNotNowEnableNotification() {
        presentTaskReminderCustomDateController()
    }
}

/// Делегаты связанные с полями: "Дата выполнения" (дедлайн), "Дата напоминания", "Период повтора"
/// и контроллерами с вариантами значений и установкой кастомного значения
extension TaskDetailViewController: TableVariantsViewControllerDelegate {
    func didChooseDateVariant(newDate: Date?, identifier: String) {
        if identifier == FieldNameIdentifier.taskDeadline.rawValue {
            viewModel.updateTaskField(deadlineDate: newDate)
        }
    }
    
    func didChooseTaskRepeatPeriodVariant(newRepeatPeriod: String?, identifier: String) {
        if identifier == FieldNameIdentifier.taskRepeatPeriod.rawValue {
            viewModel.updateTaskField(repeatPeriod: newRepeatPeriod)
        }
    }
    
    func didChooseCustomVariant(navigationController: UINavigationController?, identifier: String) {
        if identifier == FieldNameIdentifier.taskDeadline.rawValue {
            let customDateSetterVM = viewModel.getTaskDeadlineCustomDateSetterViewModel()
            let customDateVC = CustomDateSetterViewController(
                viewModel: customDateSetterVM,
                identifier: identifier
            )
            customDateVC.delegate = self
            
            navigationController?.pushViewController(customDateVC, animated: true)
        } else if identifier == FieldNameIdentifier.taskRepeatPeriod.rawValue {
            let customRepeatPeriodSetterVM = viewModel.getCustomTaskRepeatPeriodSetterViewModel()
            let customRepeatPeriodSetterVC = CustomTaskRepeatPeriodSetterViewController(
                viewModel: customRepeatPeriodSetterVM,
                identifier: identifier
            )
            customRepeatPeriodSetterVC.delegate = self
            customRepeatPeriodSetterVC.title = "Повторять каждые"
            
            navigationController?.pushViewController(customRepeatPeriodSetterVC, animated: true)
        }
    }
    
    func didChooseDeleteVariantButton(identifier: String) {
        if identifier == FieldNameIdentifier.taskDeadline.rawValue {
            viewModel.updateTaskField(deadlineDate: nil)
        } else if identifier == FieldNameIdentifier.taskRepeatPeriod.rawValue {
            viewModel.updateTaskField(repeatPeriod: nil)
        }
    }
}

extension TaskDetailViewController: CustomDateSetterViewControllerDelegate {
    func didChooseCustomDateReady(newDate: Date?, identifier: String) {
        if identifier == FieldNameIdentifier.taskDeadline.rawValue {
            viewModel.updateTaskField(deadlineDate: newDate)
        } else if identifier == FieldNameIdentifier.taskReminderDate.rawValue {
            viewModel.updateTaskField(reminderDateTime: newDate)
        }
    }
    
    func didChooseCustomDateDelete(identifier: String) {
        if identifier == FieldNameIdentifier.taskDeadline.rawValue {
            viewModel.updateTaskField(deadlineDate: nil)
        } else if identifier == FieldNameIdentifier.taskReminderDate.rawValue {
            viewModel.updateTaskField(reminderDateTime: nil)
        }
    }
}

/// Делегаты связанные с крестиками в ячейках данных задачи у полей:
/// - "Добавить в мой день" [x]
/// - "Дата напоминания" [x]
/// - "Дата выполнения" [x]
/// - "Период повтора" [x]
/// - "Прикрепленный файл" [х] - удаление
extension TaskDetailViewController: TaskDetailBaseButtonCellDelegate {
    func didTapTaskDetailCellActionButton(cellIdentifier: String, cell: UITableViewCell) {
        
        switch cellIdentifier {
        case AddToMyDayButtonCell.identifier:
            viewModel.updateTaskField(inMyDay: false)
            
        case ReminderDateButtonCell.identifier:
            viewModel.updateTaskField(reminderDateTime: nil)
            
        case DeadlineDateButtonCell.identifier:
            viewModel.updateTaskField(deadlineDate: nil)
            
        case RepeatPeriodButtonCell.identifier :
            viewModel.updateTaskField(repeatPeriod: nil)
    
        case FileButtonCell.identifier :
            let indexPath = taskDataTableView.indexPath(for: cell)
            guard let indexPath else { return }
            
            presentDeleteFileAlertController(fileCellIndexPath: indexPath)
            break
            
        default :
            break
        }
        
    }
}

extension TaskDetailViewController: CustomTaskRepeatPeriodSetterViewControllerDelegate {
    func didChooseCustomTaskRepeatPeriodReady(newPeriod: String?, identifier: String) {
        viewModel.updateTaskField(repeatPeriod: newPeriod)
    }
}

/// Делегаты связанные с полем "Описание"
extension TaskDetailViewController: TextEditorViewControllerDelegate {
    func didDisappearTextEditorViewController(text: NSAttributedString, isSuccess: Bool) {
        viewModel.updateTaskField(taskDescription: text)
    }
}

extension TaskDetailViewController: DescriptionButtonCellDelegateProtocol {
    func didTapTaskDescriptionOpenButton() {
        presentDescriptionController()
    }
}

/// Делегат для действий при выборе вариантов "откуда добавить файл"
extension TaskDetailViewController: AddFileSourceAlertControllerDelegate {
    func didChooseAddFileFromImageLibrary() {
        // TODO: сделать нормальные проверки
        guard UIImagePickerController.isSourceTypeAvailable(.photoLibrary) == true else {
            print("❌ Нет доступа к галерее")
            return
        }
        
        let availableMediaTypes = UIImagePickerController.availableMediaTypes(for: .photoLibrary)
        guard (availableMediaTypes?.count ?? 0) > 0 else {
            print("❌ нет доступных форматов в галерее")
            return
        }
        
        let imagePickerController = UIImagePickerController()
        imagePickerController.delegate = self
        imagePickerController.mediaTypes = availableMediaTypes ?? []
        
        present(imagePickerController, animated: true)
    }
    
    func didChooseAddFileFromCamera() {
        guard UIImagePickerController.isSourceTypeAvailable(.camera) == true else {
            print("❌ Нет доступа к камере")
            return
        }
        
        let availableMediaTypes = UIImagePickerController.availableMediaTypes(for: .camera)
        guard (availableMediaTypes?.count ?? 0) > 0 else {
            print("❌ нет доступных форматов у камеры")
            return
        }
        
        let imagePickerController = UIImagePickerController()
        imagePickerController.sourceType = .camera
        imagePickerController.delegate = self
        imagePickerController.mediaTypes = availableMediaTypes ?? []
        
        present(imagePickerController, animated: true)
    }
    
    func didChooseAddFileFromFiles() {
        let documentPicker = UIDocumentPickerViewController(
            forOpeningContentTypes: [.jpeg, .pdf, .text]
        )
        documentPicker.delegate = self
        documentPicker.allowsMultipleSelection = false
        
        present(documentPicker, animated: true)
    }
}

/// Делегат для взаимодействия с галереей (при загрузке файла)
extension TaskDetailViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    func imagePickerController(
        _ picker: UIImagePickerController,
        didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]
    ) {
        picker.dismiss(animated: true)
        guard let originalImage = info[.originalImage] as? UIImage else {
            return
        }
        
        let imgData = NSData(data: originalImage.jpegData(compressionQuality: 1)!)
        viewModel.createTaskFile(fromImageData: imgData)
    }
}

/// Делегат для взаимодействия с браузером файлов (при загрузке файла)
extension TaskDetailViewController: UIDocumentPickerDelegate {
    func documentPicker(
        _ controller: UIDocumentPickerViewController,
        didPickDocumentsAt urls: [URL]
    ) {
        controller.dismiss(animated: true)
        
        for url in urls {
            viewModel.createTaskFile(fromUrl: url)
            break
        }
    }
}


// MARK: binding with ViewModel delegate
extension TaskDetailViewController: TaskDetailViewModelBindingDelegate {
    func addCell(toIndexPath indexPath: IndexPath, cellViewModel: TaskDataCellViewModelType) {
        let cell = buildTableViewCellFor(cellViewModel)
        
        taskDataTableView.insertRows(at: [indexPath], with: .fade)
    }
    
    func updateCell(withIndexPath indexPath: IndexPath, cellViewModel: TaskDataCellViewModelType) {
        let cell = taskDataTableView.cellForRow(at: indexPath)
        
        switch cellViewModel {
        case _ as AddSubTaskCellViewModel:
            break
            
        case let cellVM as AddToMyDayCellViewModel:
            guard let cell = cell as? AddToMyDayButtonCell else { return }
            cell.fillFrom(cellVM)
        
        case let cellVM as ReminderDateCellViewModel:
            guard let cell = cell as? ReminderDateButtonCell else { return }
            cell.fillFrom(cellVM)
            
        case let cellVM as DeadlineDateCellViewModel:
            guard let cell = cell as? DeadlineDateButtonCell else { return }
            cell.fillFrom(cellVM)
            
        case let cellVM as RepeatPeriodCellViewModel:
            guard let cell = cell as? RepeatPeriodButtonCell else { return }
            cell.fillFrom(cellVM)
            
        case _ as AddFileCellVeiwModel:
            break
        
        case let cellVM as FileCellViewModel:
            guard let cell = cell as? FileButtonCell else { return }
            cell.fillFrom(cellValue: cellVM)
            
        case let cellVM as DescriptionCellViewModel:
            guard let cell = cell as? DescriptionButtonCell else { return }
            cell.fillFrom(cellVM)
            
        default :
            // TODO: залогировать
            break
        }
    }
    
    func removeCells(withIndexPaths indexPaths: [IndexPath]) {
        taskDataTableView.deleteRows(at: indexPaths, with: .fade)
    }
}
