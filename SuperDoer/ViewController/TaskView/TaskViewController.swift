
import UIKit

/// Контроллер задачи
// MARK: MAIN
class TaskViewController: UIViewController {
    
    // TODO: переделать на DI-контейнер
    lazy var taskEm = TaskEntityManager()
    lazy var taskFileEm = TaskFileEntityManager()
    
    // MARK: controls
    lazy var taskDoneButton = CheckboxButton()
    lazy var taskTitleTextView = UITaskTitleTextView()
    lazy var isPriorityButton = StarButton()
    
    lazy var taskDataTableView = TaskDataTableView(frame: .zero, style: .plain)
    
    
    /// Редактируемое в данный момент поле TextField
    var textFieldEditing: UITextField?
    
    /// Массив на основании которого формируется таблица с "кнопками" и данными задачи
    var taskDataCellsValues = TaskDataCellValues()
    
    
    // MARK: model
    var task: Task
    
    
    // MARK: init
    init(task: Task) {
        self.task = task
        
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
    
//        PixelPerfectScreen.getInstanceAndSetup(baseView: view)  // TODO: удалить временный код (perfect pixel screen)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        fillControls(from: task)
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
    
    private func setTaskReminder(_ remindButton: RemindButtonCell) {
        // TODO: сделать проверку включены ли уведомления для приложения
        let isEnableNotifications = false
        if !isEnableNotifications {
            let notificationDisableAlert = NotificationDisabledAlertController()
            notificationDisableAlert.delegate = self
            
            present(notificationDisableAlert, animated: true)
        } else {
            
        }
    }
    
    private func showDeadlineSettingsController(_ task: Task) {
        let deadlineVariantsController = DeadlineVariantsViewController(task: task)
        deadlineVariantsController.delegate = self
        let navigationController = UINavigationController(rootViewController: deadlineVariantsController)
        
        present(navigationController, animated: true)
    }
    
    
//    private func presentDeadlineViewController() {
//        let deadlineVariantsController = DeadlineVariantsViewController()
//
//        present(deadlineVariantsController, animated: true)
////        show(deadlineController, sender: nil)
//
//
//
////        deadlineCalendarController.preferredContentSize = CGSize(width: 300, height: 400)
//
////        deadlineCalendarController.view.frame =
//
//        // при present
////            .popover
////            .formSheet // ???
////            .pageSheet // откроется поверх родительского с оттеснением родительского дальше (родительский будет видно)
//
////            .currentContext // откроется на весь экран (родительский контроллер не будет видно) (вьюхи родительского контроллера тоже удаляются)
////            .fullScreen // на весь экран (вьюхи родительского vc удаляются, когда открывается такой vc)
//    }
    
    
    private func presentDeleteFileAlertController(fileIndexPath indexPath: IndexPath) {
        let fileDeleteAlert = FileDeleteAlertController(fileIndexPath: indexPath) { indexPath in
            self.deleteFile(fileCellIndexPath: indexPath)
        }
        
        present(fileDeleteAlert, animated: true)
    }
    
    private func deleteFile(fileCellIndexPath indexPath: IndexPath) {
        let cellValue = taskDataCellsValues.cellsValuesArray[indexPath.row]
        if let fileCellValue = cellValue as? FileCellValue {

            let taskFile = task.getFileBy(id: fileCellValue.id)
            if let safeTaskFile = taskFile {
                self.taskFileEm.delete(file: safeTaskFile)
            }
            
            taskDataCellsValues.cellsValuesArray.remove(at: indexPath.row)
            taskDataTableView.deleteRows(at: [indexPath], with: .fade)
        }
    }
    
    private func presentAddFileAlertController() {
        let addFileAlertController = AddFileAlertController(controller: self)
        
        present(addFileAlertController, animated: true)
    }
    
    
    private func presentDescriptionController() {
        let taskDescriptionController = TaskDescriptionViewController(task: task)
        taskDescriptionController.dismissDelegate = self
        
        present(taskDescriptionController, animated: true)
    }
    
    
    private func fillControls(from task: Task) {
        taskTitleTextView.text = task.title
        taskDoneButton.isOn = task.isCompleted
        isPriorityButton.isOn = task.isPriority
        
        taskDataCellsValues.fill(from: task)
        if !taskDataTableView.visibleCells.isEmpty {
            taskDataTableView.reloadData()
        }
    }
    
    
    // MARK: notifications handler

}

/// Расширение для инкапсуляции настройки контролов и макета
// MARK: SETUP LAYOUT
extension TaskViewController {
    
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
        
        // buttonsTableView
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
}


// MARK: table delegate and dataSource
extension TaskViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return taskDataCellsValues.cellsValuesArray.count
    }
    
    
    // MARK: cell appearance
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let buttonValue = taskDataCellsValues.cellsValuesArray[indexPath.row]
        let cell: UITableViewCell
        
        switch buttonValue {
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
        
        case _ as RemindCellValue:
            cell = taskDataTableView.dequeueReusableCell(withIdentifier: RemindButtonCell.identifier)!
            
        case let deadlineCellValue as DeadlineCellValue:
            cell = taskDataTableView.dequeueReusableCell(withIdentifier: TaskDataDeadlineCell.identifier)!
            if let deadlineCell = cell as? TaskDataDeadlineCell {
                deadlineCell.fillFrom(deadlineCellValue)
                deadlineCell.delegate = self
            }
            
        case _ as RepeatCellValue:
            cell = taskDataTableView.dequeueReusableCell(withIdentifier: RepeatButtonCell.identifier)!
            
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
            cell = taskDataTableView.dequeueReusableCell(withIdentifier: TaskViewLabelsButtonCell.identifier)!
            if cell is TaskViewLabelsButtonCell {
//                buttonWithLabel.mainTextLabel.text = buttonValue.maintext
            }
        }
        
        return cell
    }

    
    // MARK: select row
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let cell = tableView.cellForRow(at: indexPath)
        let _ = taskDataCellsValues.cellsValuesArray[indexPath.row]
        
        switch cell {
        case let addSubtaskButton as AddSubtaskButtonCell :
            addSubtaskButton.subtaskTextField.becomeFirstResponder()
        
        case _ as AddToMyDayButtonCell :
            taskEm.updateField(inMyDay: !task.inMyDay, task: task)
            
            taskDataCellsValues.fillAddToMyDay(from: task)
            taskDataTableView.reloadData()
        
        case let remindButton as RemindButtonCell :
            setTaskReminder(remindButton)
            
        case _ as TaskDataDeadlineCell :
            showDeadlineSettingsController(task)
            break
            
        case _ as RepeatButtonCell :
            print("🔁 Открылись настройки повтора задачи")
            
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

        tableView.reloadData()
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
        if taskDataCellsValues.cellsValuesArray[indexPath.row] is FileCellValue {
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
    

//    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
//        if editingStyle == .delete {
//            buttonsArray.remove(at: indexPath.row)
//            buttonsTableView.deleteRows(at: [indexPath], with: .fade)
//        }
//    }

}


// MARK: task title TextView delegate
extension TaskViewController: UITextViewDelegate {
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
        taskEm.updateField(title: textView.text, task: task)
    }

    // TODO: заменять перевод строки на пробел когда заканчивается редактирование названия
}


// MARK: subtask TextField delegate
extension TaskViewController: UITextFieldDelegate {
    func textFieldDidBeginEditing(_ textField: UITextField) {
        showSubtaskAddNavigationItemReady()
        textFieldEditing = textField
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
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
extension TaskViewController: CheckboxButtonDelegate {
    func checkboxDidChangeValue(checkbox: CheckboxButton) {
        taskEm.updateField(isCompleted: checkbox.isOn, task: task)
    }
}

/// Протокол связанный с полем "Приоритет"
extension TaskViewController: StarButtonDelegate {
    func starButtonValueDidChange(starButton: StarButton) {
        taskEm.updateField(isPriority: starButton.isOn, task: task)
    }
}

/// Делегаты связанные с полем "Описание"
extension TaskViewController: TaskDescriptionViewControllerDelegate, DescriptionButtonCellDelegateProtocol {
    func didDisappearTaskDescriptionViewController(isSuccess: Bool) {
        taskDataCellsValues.fillDescription(from: task)
        taskDataTableView.reloadData()
    }
    
    func pressTaskDescriptionOpenButton() {
        presentDescriptionController()
    }
}

/// Делегат связанный с полем "Добавить в мой день"
extension TaskViewController: AddToMyDayButtonCellDelegate {
    func tapAddToMyDayCrossButton() {
        taskEm.updateField(inMyDay: false, task: task)
        
        taskDataCellsValues.fillAddToMyDay(from: task)
        taskDataTableView.reloadData()
    }
}

/// Делегат связанный с полем "Напомнить"
extension TaskViewController: NotificationsDisabledAlertControllerDelegate {
    func didChoosenEnableNotifications() {
        // TODO: открыть контроллер установки напоминаний
    }
    
    func didChoosenNotNowEnableNotification() {
        // TODO: открыть контроллер установки напоминаний
    }
}

/// Методы делегата связанные с полем "Дата выполнения"
extension TaskViewController: TaskDataDeadlineCellDelegate, DeadlineSettingsViewControllerDelegate {
    func tapTaskDeadlineCrossButton() {
        taskEm.updateField(deadlineDate: nil, task: task)

        taskDataCellsValues.fillDeadlineAt(from: task)
        taskDataTableView.reloadData()
    }
    
    func didChooseDeadlineDate(newDate: Date?) {
        taskEm.updateField(deadlineDate: newDate, task: task)
        
        taskDataCellsValues.fillDeadlineAt(from: task)
        taskDataTableView.reloadData()
    }
}

/// Делегат для взаимодействия с галереей (при загрузке файла)
extension TaskViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        
        guard let originalImage = info[.originalImage] as? UIImage else {
            picker.dismiss(animated: true)
            return
        }
        
        picker.dismiss(animated: true)
        
        let imgData = NSData(data: originalImage.jpegData(compressionQuality: 1)!)
        
        // TODO: вынести в EM
        let taskFile = taskFileEm.createWith(
            fileName: "Фото размером \(imgData.count) kb",
            fileExtension: "jpg",
            fileSize: imgData.count,
            task: task
        )
        taskFileEm.saveContext()
        
        let indexNewFile = taskDataCellsValues.appendFile(taskFile)
        taskDataTableView.insertRows(at: [IndexPath(row: indexNewFile, section: 0)], with: .fade)
    }
}

extension TaskViewController: UIDocumentPickerDelegate {
    func documentPicker(_ controller: UIDocumentPickerViewController, didPickDocumentsAt urls: [URL]) {
    
        for url in urls {
            let taskFile = taskFileEm.createWith(
                fileName: "Файл размером ??? kb",
                fileExtension: url.pathExtension,
                fileSize: 0,
                task: task
            )
            taskFileEm.saveContext()
            
            let indexNewFile = taskDataCellsValues.appendFile(taskFile)
            taskDataTableView.insertRows(at: [IndexPath(row: indexNewFile, section: 0)], with: .fade)
            
            break
        }
        
        controller.dismiss(animated: true)
    }
}



// MARK: task cell values
class TaskDataCellValues {
    var cellsValuesArray = [TaskDataCellValueProtocol]()
    
    /// Полностью обновляет все данные для таблицы на основании task
    func fill(from task: Task) {
        cellsValuesArray.removeAll()
        
        cellsValuesArray.append(AddSubTaskCellValue())
        // TODO: подзадачи
        
        cellsValuesArray.append(AddToMyDayCellValue(inMyDay: task.inMyDay))
        cellsValuesArray.append(RemindCellValue(dateTime: task.reminderDateTime))
        
        cellsValuesArray.append(DeadlineCellValue(date: task.deadlineDate))
        cellsValuesArray.append(RepeatCellValue())
        cellsValuesArray.append(AddFileCellValue())
        
        
        for file in task.files ?? []  {
            guard let taskFile = file as? TaskFile else {
                // TODO: залогировать ошибку
                continue
            }
            
            cellsValuesArray.append(
                FileCellValue(
                    id: taskFile.id!,
                    name: taskFile.fileName!,
                    fileExtension: taskFile.fileExtension!,
                    size: Int(taskFile.fileSize)
                )
            )
        }
        
        cellsValuesArray.append(
            DescriptionCellValue(contentAsHtml: task.taskDescription, dateUpdatedAt: task.descriptionUpdatedAt)
        )
    }
    
    func fillAddToMyDay(from task: Task) {
        for (index, buttonValue) in cellsValuesArray.enumerated() {
            if var addToMyDayCellValue = buttonValue as? AddToMyDayCellValue {
                addToMyDayCellValue.inMyDay = task.inMyDay

                cellsValuesArray[index] = addToMyDayCellValue
                break
            }
        }
    }
    
    func fillDeadlineAt(from task: Task) {
        for (index, buttonValue) in cellsValuesArray.enumerated() {
            if var deadlineAtCellValue = buttonValue as? DeadlineCellValue {
                deadlineAtCellValue.date = task.deadlineDate

                cellsValuesArray[index] = deadlineAtCellValue
                break
            }
        }
    }
    
    func appendFile(_ file: TaskFile) -> RowIndex {
        let indexOfLastFile = getIndexOfLastFileOrAddFileButton()
        
        guard let safeIndexOfLastFile = indexOfLastFile else {
            print("no index")
            // TODO: надо кинуть ошибку или залогировать т.к файл или кнопка добавить файл точно должна быть
            return 0
        }
        let indexNewFile = safeIndexOfLastFile + 1
        
        cellsValuesArray.insert(
            FileCellValue(
                id: file.id!,
                name: file.fileName!,
                fileExtension: file.fileExtension!,
                size: Int(file.fileSize)
            ),
            at: indexNewFile
        )
        
        return indexNewFile
    }
    
    func fillDescription(from task: Task) {
        for (index, buttonValue) in cellsValuesArray.enumerated() {
            if var descriptionCellValue = buttonValue as? DescriptionCellValue {
                // TODO: сконвертировать нормально хранимый string в NSAttributedString
                if let safeContent = task.taskDescription {
                    descriptionCellValue.content = NSAttributedString(string: safeContent)
                } else {
                    descriptionCellValue.content = nil
                }
                descriptionCellValue.updatedAt = task.descriptionUpdatedAt

                cellsValuesArray[index] = descriptionCellValue
                break
            }
        }
    }
    
    
    private func getIndexOfLastFileOrAddFileButton() -> Int? {
        var result: Int? = nil
        for (index, cellValue) in cellsValuesArray.enumerated() {
            if cellValue is AddFileCellValue || cellValue is FileCellValue {
                result = index
            }
        }
        
        return result
    }
}

typealias RowIndex = Int
