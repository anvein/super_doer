
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
    
    @objc func pressedFileDeleteTouchUpInside(sender: UIButton) {
        let cell = sender.superview?.superview
        guard let fileButtonCell = cell as? FileButtonCell else {
            return
        }
        
        guard let indexPath = taskDataTableView.indexPath(for: fileButtonCell) else {
            return
        }
        
        presentDeleteFileAlertController(fileIndexPath: indexPath)
    }
    
    
    // MARK: other methods
    
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
        
        let deadlineVariantsController = PageSheetTableVariantsViewController(
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
        
        let variantsController = PageSheetTableVariantsViewController(
            viewModel: vm,
            identifier: FieldNameIdentifier.taskRepeatPeriod.rawValue
        )
        variantsController.delegate = self
        variantsController.title = "Повтор"
        let navigationController = UINavigationController(rootViewController: variantsController)
        
        present(navigationController, animated: true)
    }
    
    private func presentDeleteFileAlertController(fileIndexPath indexPath: IndexPath) {
        let fileDeleteAlert = FileDeleteAlertController(fileIndexPath: indexPath) { indexPath in
            self.deleteFile(fileCellIndexPath: indexPath)
        }
        
        present(fileDeleteAlert, animated: true)
    }
    
    private func deleteFile(fileCellIndexPath indexPath: IndexPath) {
//        let cellValue = taskDataCellsValues.cellsValuesArray[indexPath.row]
//        if let fileCellValue = cellValue as? FileCellValue {
//
//            let taskFile = task.getFileBy(id: fileCellValue.id)
//            if let safeTaskFile = taskFile {
//                self.taskFileEm.delete(file: safeTaskFile)
//            }
//            
//            taskDataCellsValues.cellsValuesArray.remove(at: indexPath.row)
//            taskDataTableView.deleteRows(at: [indexPath], with: .fade)
//        }
    }
    
    private func presentAddFileAlertController() {
        let addFileAlertController = AddFileAlertController(controller: self)
        
        present(addFileAlertController, animated: true)
    }
    
    private func presentDescriptionController() {
        let vm = viewModel.getTaskDescriptionEditorViewModel()
        let vc = TextEditorViewController(viewModel: vm)
        vc.dismissDelegate = self
        
        present(vc, animated: true)
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
        
        // buttonsTableView
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
        
        viewModel.setupBindingTaskDataCellsValues(listener: {[unowned self]  taskDataCellsValues in
            // TODO: сделать красивое обновление
            self.taskDataTableView.reloadData()
        })
    }
}


// MARK: table delegate and dataSource
extension TaskDetailViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return viewModel.countTaskDataCellsValues
    }
    
    
    // MARK: cell appearance
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cellValue = viewModel.getTaskDataCellValueFor(indexPath: indexPath)
        let cell: UITableViewCell

        switch cellValue {
        case _ as AddSubTaskCellValue:
            cell = taskDataTableView.dequeueReusableCell(withIdentifier: AddSubtaskButtonCell.identifier)!
            if let addSubtaskButtonCell = cell as? AddSubtaskButtonCell {
                addSubtaskButtonCell.subtaskTextField.delegate = self
            }
            
        case let addToMyDayCellValue as AddToMyDayCellValue:
            cell = taskDataTableView.dequeueReusableCell(withIdentifier: AddToMyDayButtonCell.identifier)!
            if let addToMyDayButtonCell = cell as? AddToMyDayButtonCell {
                addToMyDayButtonCell.isOn = addToMyDayCellValue.inMyDay
                addToMyDayButtonCell.delegate = self
            }
        
        case let reminderDateCellValue as ReminderDateCellValue:
            cell = taskDataTableView.dequeueReusableCell(withIdentifier: ReminderDateButtonCell.identifier)!
            if let reminderDateCell = cell as? ReminderDateButtonCell {
                reminderDateCell.fillFrom(reminderDateCellValue)
                reminderDateCell.delegate = self
            }
            
        case let deadlineCellValue as DeadlineDateCellValue:
            cell = taskDataTableView.dequeueReusableCell(withIdentifier: DeadlineDateButtonCell.identifier)!
            if let deadlineCell = cell as? DeadlineDateButtonCell {
                deadlineCell.fillFrom(deadlineCellValue)
                deadlineCell.delegate = self
            }
            
        case let repeatPeriodCellValue as RepeatPeriodCellValue:
            cell = taskDataTableView.dequeueReusableCell(withIdentifier: RepeatPeriodButtonCell.identifier)!
            if let repeatPeriodCell = cell as? RepeatPeriodButtonCell {
                repeatPeriodCell.fillFrom(repeatPeriodCellValue)
                repeatPeriodCell.delegate = self
            }
            
        case _ as AddFileCellValue:
            cell = taskDataTableView.dequeueReusableCell(withIdentifier: AddFileButtonCell.identifier)!
        
        case let fileCellValue as FileCellValue:
            cell = taskDataTableView.dequeueReusableCell(withIdentifier: FileButtonCell.identifier)!
            if let fileButtonCell = cell as? FileButtonCell {
                fileButtonCell.fillFrom(cellValue: fileCellValue)
                
                // TODO: переделать на делегата
                fileButtonCell.actionButton.addTarget(
                    self,
                    action: #selector(pressedFileDeleteTouchUpInside(sender:)),
                    for: .touchUpInside
                )
            }
            
        case let descriptionCellValue as DescriptionCellValue:
            cell = taskDataTableView.dequeueReusableCell(withIdentifier: DescriptionButtonCell.identifier)!
            if let descriptionButtonCell = cell as? DescriptionButtonCell {
                descriptionButtonCell.delegate = self
                descriptionButtonCell.fillCellData(content: descriptionCellValue.content, updatedAt: descriptionCellValue.updatedAt)
            }
            
        default :
            cell = taskDataTableView.dequeueReusableCell(withIdentifier: TaskDetailLabelsButtonCell.identifier)!
            if let cell = cell as? TaskDetailLabelsButtonCell {
                cell.mainTextLabel.text = "Ошибка получения данных"
                // TODO: залогировать
            }
        }
        
        return cell
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
        let deleteAction = UIContextualAction(style: .destructive, title: nil) { deleteAction, view, completionHandler in
            self.presentDeleteFileAlertController(fileIndexPath: indexPath)
            
            completionHandler(true)
        }
        let symbolConfig = UIImage.SymbolConfiguration(pointSize: 14, weight: .bold)
        deleteAction.image = UIImage(systemName: "trash", withConfiguration: symbolConfig)
        
        // TODO: сделать чтобы действие подкрашивалось серым до определенной степени свайпа, а потом становилось красным
        // TODO: + чтобы если свайпнуто больше основной части, то чтобы сразу запускалось действие
        
        return UISwipeActionsConfiguration(actions: [deleteAction])
    }

    
    // MARK: "edit" / delete row
    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
//        if taskDataCellsValues.cellsValuesArray[indexPath.row] is FileCellValue {
//            return true
//        }
        
        return false
    }

    func tableView(_ tableView: UITableView, editingStyleForRowAt indexPath: IndexPath) -> UITableViewCell.EditingStyle {
        return .none
    }
    
    func tableView(_ tableView: UITableView, shouldIndentWhileEditingRowAt indexPath: IndexPath) -> Bool {
        return false
    }

//    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
//        if editingStyle == .delete {
//            buttonsArray.remove(at: indexPath.row)
//            buttonsTableView.deleteRows(at: [indexPath], with: .fade)
//        }
//    }

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
    func checkboxDidChangeValue(checkbox: CheckboxButton) {
//        taskEm.updateField(isCompleted: checkbox.isOn, task: task)
    }
}

/// Протокол связанный с полем "Приоритет"
extension TaskDetailViewController: StarButtonDelegate {
    func starButtonValueDidChange(starButton: StarButton) {
//        taskEm.updateField(isPriority: starButton.isOn, task: task)
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
extension TaskDetailViewController: PageSheetTableVariantsViewControllerDelegate {
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
extension TaskDetailViewController: TaskDetailBaseButtonCellDelegate {
    func didTapTaskDetailCellActionButton(cellIdentifier: String) {
        
        switch cellIdentifier {
        case AddToMyDayButtonCell.identifier:
            viewModel.updateTaskField(inMyDay: false)
            
        case ReminderDateButtonCell.identifier:
            viewModel.updateTaskField(reminderDateTime: nil)
            
        case DeadlineDateButtonCell.identifier:
            viewModel.updateTaskField(deadlineDate: nil)
            
        case RepeatPeriodButtonCell.identifier :
            viewModel.updateTaskField(repeatPeriod: nil)
    
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

/// Делегат для взаимодействия с галереей (при загрузке файла)
extension TaskDetailViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        
//        guard let originalImage = info[.originalImage] as? UIImage else {
//            picker.dismiss(animated: true)
//            return
//        }
//        
//        picker.dismiss(animated: true)
//        
//        let imgData = NSData(data: originalImage.jpegData(compressionQuality: 1)!)
//        
//        // TODO: вынести в EM
//        let taskFile = taskFileEm.createWith(
//            fileName: "Фото размером \(imgData.count) kb",
//            fileExtension: "jpg",
//            fileSize: imgData.count,
//            task: task
//        )
//        taskFileEm.saveContext()
//        
//        let indexNewFile = taskDataCellsValues.appendFile(taskFile)
//        taskDataTableView.insertRows(at: [IndexPath(row: indexNewFile, section: 0)], with: .fade)
    }
}

extension TaskDetailViewController: UIDocumentPickerDelegate {
    func documentPicker(_ controller: UIDocumentPickerViewController, didPickDocumentsAt urls: [URL]) {
//    
//        for url in urls {
//            let taskFile = taskFileEm.createWith(
//                fileName: "Файл размером ??? kb",
//                fileExtension: url.pathExtension,
//                fileSize: 0,
//                task: task
//            )
//            taskFileEm.saveContext()
//            
//            let indexNewFile = taskDataCellsValues.appendFile(taskFile)
//            taskDataTableView.insertRows(at: [IndexPath(row: indexNewFile, section: 0)], with: .fade)
//            
//            break
//        }
//        
//        controller.dismiss(animated: true)
    }
}
