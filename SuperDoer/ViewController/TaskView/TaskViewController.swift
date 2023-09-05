
import UIKit

/// Контроллер задачи
// MARK: MAIN
class TaskViewController: UIViewController {

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
    
        PixelPerfectScreen.getInstanceAndSetup(baseView: view)  // TODO: удалить временный код (perfect pixel screen)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        fillControls(from: task)
    }
    
    
    // MARK: controller action-handlers
    @objc func buttonMenuAction1(_: Int) {
        print("Пункт меню 1")
    }
    
    @objc func someTextFieldEvent(sender: UITextField, event: UIEvent) {
        print("aa")
//        print(event.subtype)
//        print(event.type, event.subtype)
    }
    
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
        let isEnableNotifications = true
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
            task.deleteFile(by: fileCellValue.id)
            
            taskDataCellsValues.cellsValuesArray.remove(at: indexPath.row)
            taskDataTableView.reloadData()
        }
    }
    
    private func presentAddFileAlertController() {
        let addFileAlertController = AddFileAlertController(taskViewController: self)
        
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
        
        // taskTitleTextView
        taskTitleTextView.delegate = self
        
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
                fileButtonCell.fillFromCellValue(cellValue: fileCellValue)
                fileButtonCell.actionButton.addTarget(
                    self,
                    action: #selector(pressedFileDeleteTouchUpInside(sender:)),
                    for: .touchUpInside
                )
            }
            
        case let descriprionCellValue as DescriptionCellValue:
            cell = taskDataTableView.dequeueReusableCell(withIdentifier: DescriptionButtonCell.identifier)!
            if let descriptionButtonCell = cell as? DescriptionButtonCell {
                descriptionButtonCell.delegate = self
                descriptionButtonCell.fillCellData(mainText: descriprionCellValue.text, dateUpdated: descriprionCellValue.dateUpdated)
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
        let cellValue = taskDataCellsValues.cellsValuesArray[indexPath.row]
        
        switch cell {
        case let addSubtaskButton as AddSubtaskButtonCell :
            addSubtaskButton.subtaskTextField.becomeFirstResponder()
        
        case _ as AddToMyDayButtonCell :
            task.inMyDay = !task.inMyDay
            taskDataCellsValues.fillAddToMyDay(from: task)
            taskDataTableView.reloadData()
        
        case let remindButton as RemindButtonCell :
            setTaskReminder(remindButton)
            
        case _ as TaskDataDeadlineCell :
            showDeadlineSettingsController(task)
            
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
        }
        
        return true
    }
    
    func textViewShouldBeginEditing(_ textView: UITextView) -> Bool {
        showTaskTitleNavigationItemReady()
        
        return true
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
        task.inMyDay = false
        
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
        task.deadlineDate = nil
        
        taskDataCellsValues.fill(from: task)
        taskDataTableView.reloadData()
    }
    
    func didDisappearDeadlineSettingsViewController(isSuccess: Bool) {
        fillControls(from: task)
        taskDataTableView.reloadData()
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
        cellsValuesArray.append(RemindCellValue())
        
        cellsValuesArray.append(DeadlineCellValue(date: task.deadlineDate))
        cellsValuesArray.append(RepeatCellValue())
        cellsValuesArray.append(AddFileCellValue())
        
        for file in task.files {
            cellsValuesArray.append(
                FileCellValue(id: file.id, name: file.name, fileExtension: file.fileExtension, size: file.size)
            )
        }
        
        cellsValuesArray.append(
            DescriptionCellValue(text: task.description, dateUpdated: task.descriptionUpdated)
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
    
    func fillDescription(from task: Task) {
        for (index, buttonValue) in cellsValuesArray.enumerated() {
            if var descriptionCellValue = buttonValue as? DescriptionCellValue {
                descriptionCellValue.text = task.description
                descriptionCellValue.dateUpdated = task.descriptionUpdated
                
                cellsValuesArray[index] = descriptionCellValue
                break
            }
        }
    }
}
