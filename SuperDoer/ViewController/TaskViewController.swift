
import UIKit

/// Контроллер задачи
// MARK: MAIN
class TaskViewController: UIViewController {

    // MARK: controls
    lazy var taskDoneButton = CheckboxButton()
    
    lazy var taskTitleTextView = UITextView()
    var taskTitleTextViewDelegate: TaskTitleTextViewDelegate?
    
    lazy var isPriorityButton = StarButton()
    
    lazy var buttonsTableView = TaskViewButtonsTableView(frame: .zero, style: .plain)
    
    
    
    
    
    
    /// Редактируемое в данный момент поле TextField
    var textFieldEditing: UITextField?
    
    
    
    
    // TODO: temp controls
    var isViewScreen = false
    lazy var screenIsVisibleSwitch = UISwitch()
    lazy var screenOpacitySlider = UISlider()
    let screenImageView = UIImageView(image: UIImage(named: "screen"))
    
    
    // MARK: model
    var task: Task
    
    var buttonsArray: [ButtonCellValueProtocol] = [
//        AddSubTaskCellValue(),
//        AddToMyDayCellValue(),
//        RemindCellValue(),
//        DeadlineCellValue(),
//        RepeatCellValue(),
//        FileCellValue(fileExtension: "fga", fileName: "marcedes cla.fga", fileSize: "2,5 МБ"),
//        FileCellValue(fileExtension: "mov", fileName: "Видео из файла 13.08.2023, 22.38 в 12342314", fileSize: "1.7 МБ"),
//        AddFileCellValue(),
//        DescriptionCellValue(text: NSAttributedString(string: "Текст описания задачи\nВторая строка описания\nТретья"), dateUpdated: "Обновлено")
    ]
    
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
        
        navigationItem.largeTitleDisplayMode = .never
        
        setupControls()
        addSubviews()
        setupConstraints()
        
//        self.navigationItem.rightBarButtonItem = self.editButtonItem
//        self.navigationItem.rightBarButtonItem?.action = #selector(editTableEnable)
    }
    
//    @objc func editTableEnable() {
//        buttonsTableView.isEditing = !buttonsTableView.isEditing
//        print("isEditing = \(buttonsTableView.isEditing)")
//    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        navigationController?.navigationBar.tintColor = .systemBlue
        
        fillButtonsArray(from: task)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        setBackButtonTitle()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
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
        
        guard let indexPath = buttonsTableView.indexPath(for: fileButtonCell) else {
            return
        }
        
        presentDeleteFileAlertController(fileIndexPath: indexPath)
    }
    
    
    // MARK: method handlers
    
    private func setTaskReminder(_ remindButton: RemindButtonCell) {
        // TODO: сделать проверку включены ли уведомления для приложения
        let isEnableNotifications = false
        if !isEnableNotifications {
            let notificationDisableAlert = NotificationDisabledAlertController()
            
            present(notificationDisableAlert, animated: true)
        }
        
        // TODO: открывать контроллер с выбором даты + подгрузить данные из модели
        // если пользователь не установил ничего, то закрыть контроллер установки даты и оставить поле пустым
        // если установил дату, то закрыть контроллер установки даты, записать в модель, изменить стейт кнопки
        
         remindButton.state = .defined
        
    }

    private func presentTaskDeadlineViewController() {
        let deadlineController = PageSheetDealineViewController()
        

        
        
        present(deadlineController, animated: true)
//        show(deadlineController, sender: nil)


        
        
//        deadlineCalendarController.preferredContentSize = CGSize(width: 300, height: 400)
        
//        deadlineCalendarController.view.frame =
        
        // при present
//            .popover
//            .formSheet // ???
//            .pageSheet // откроется поверх родительского с оттеснением родительского дальше (родительский будет видно)
        
//            .currentContext // откроется на весь экран (родительский контроллер не будет видно) (вьюхи родительского контроллера тоже удаляются)
//            .fullScreen // на весь экран (вьюхи родительского vc удаляются, когда открывается такой vc)
    }
    
    private func presentDeleteFileAlertController(fileIndexPath indexPath: IndexPath) {
        let fileDeleteAlert = FileDeleteAlertController(fileIndexPath: indexPath) { indexPath in
            self.deleteFile(fileCellIndexPath: indexPath)
        }
        
        present(fileDeleteAlert, animated: true)
    }
    
    private func deleteFile(fileCellIndexPath indexPath: IndexPath) {
        buttonsArray.remove(at: indexPath.row)
        buttonsTableView.deleteRows(at: [indexPath], with: .fade)
    }
    
    private func showAddFileAlertController() {
        let addFileAlertController = AddFileAlertController(taskViewController: self)
        
        present(addFileAlertController, animated: true)
    }
    
    private func fillButtonsArray(from task: Task) {
        buttonsArray.removeAll()
        
        buttonsArray.append(AddSubTaskCellValue())
        // TODO: подзадачи
        
        buttonsArray.append(AddToMyDayCellValue(inMyDay: task.isMyDay))
        buttonsArray.append(RemindCellValue())
        buttonsArray.append(DeadlineCellValue())
        buttonsArray.append(RepeatCellValue())
        buttonsArray.append(AddFileCellValue())
        
        // TODO: файлы
        
        buttonsArray.append(DescriptionCellValue(text: task.description))
    }
    
    private func fillControls(from task: Task) {
        
        if taskTitleTextView.text != task.title {
            taskTitleTextView.text = task.title
        }
        
        taskDoneButton.isOn = task.isCompleted
        isPriorityButton.isOn = task.isPriority
        
        
        for (index, cellValue) in buttonsArray.enumerated() {
            switch cellValue {
            case var isMyDayCellValue as AddToMyDayCellValue :
                isMyDayCellValue.inMyDay = task.isMyDay
                
                buttonsArray[index] = isMyDayCellValue
                
            case var descriptionCellValue as DescriptionCellValue :
                if descriptionCellValue.text != task.description {
                    descriptionCellValue.text = task.description
                }
                
                buttonsArray[index] = descriptionCellValue
            default:
                break
            }
        }
        
        buttonsTableView.reloadData()
    }
    
    // MARK: notifications handler
    
    // MARK: other methods
    
    private func setBackButtonTitle() {
        navigationController?.navigationBar.backItem?.backBarButtonItem = UIBarButtonItem(
            title: navigationController?.navigationBar.backItem?.title,
            style: .plain,
            target: nil,
            action: nil
        )
        
        navigationController?.navigationBar.backItem?.backBarButtonItem?.tintColor = InterfaceColors.textBlue
    }
}

/// Расширение для инкапсуляции настройки контролов и макета
// MARK: SETUP LAYOUT
extension TaskViewController {
    
    // MARK: add subviews & constraints
    private func addSubviews() {
        view.addSubview(taskDoneButton)
        view.addSubview(taskTitleTextView)
        view.addSubview(isPriorityButton)

        view.addSubview(buttonsTableView)

        addScreenControls()
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
            buttonsTableView.topAnchor.constraint(equalTo: taskTitleTextView.bottomAnchor),
            buttonsTableView.leftAnchor.constraint(equalTo: view.leftAnchor),
            buttonsTableView.rightAnchor.constraint(equalTo: view.rightAnchor),
            buttonsTableView.bottomAnchor.constraint(equalTo: screenIsVisibleSwitch.topAnchor),
        ])

        
        addConstraintScreenControls()
    }
    
    
    // MARK: setup controls methods (of instance)
    private func setupControls() {
        setupViewOfController()
        
        setupTaskDoneButton()
        setupTaskTitleTextView()
        setupIsPriorityButton()
        
        setupButtonsTableView()
    
        setupScreenVisibleControls()
//        setToolbarItems([
//            UIBarButtonItem(title: "Заголовок")
//        ], animated: true)
    }
    
    private func setupViewOfController() {
        view.backgroundColor = .white
        
        navigationController?.navigationBar.tintColor = InterfaceColors.textBlue
        
        // TODO: удалить
        switchScreenIsVisible(false)
    }
    
    
    private func setupTaskDoneButton() {
        taskDoneButton.isOn = task.isCompleted
    }
    
    private func setupTaskTitleTextView() {
        taskTitleTextView.translatesAutoresizingMaskIntoConstraints = false
        
        taskTitleTextView.isScrollEnabled = false
        taskTitleTextView.returnKeyType = .done
        
        taskTitleTextView.backgroundColor = InterfaceColors.white
        taskTitleTextView.textColor = InterfaceColors.blackText
        taskTitleTextView.font = UIFont.systemFont(ofSize: 22, weight: .medium)
        taskTitleTextViewDelegate = TaskTitleTextViewDelegate(textView: taskTitleTextView, viewController: self)
        taskTitleTextView.delegate = taskTitleTextViewDelegate
        
        taskTitleTextView.text = task.title
    }
    
    private func setupIsPriorityButton() {
        isPriorityButton.isOn = task.isPriority
    }
    
    private func setupButtonsTableView() {
        buttonsTableView.dataSource = self
        buttonsTableView.delegate = self
    }
    
}

// MARK: table delegate and dataSource
extension TaskViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return buttonsArray.count
    }
    
    
    // MARK: cell appearance
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let buttonValue = buttonsArray[indexPath.row]
        let cell: UITableViewCell
        
        switch buttonValue {
        case _ as AddSubTaskCellValue:
            cell = buttonsTableView.dequeueReusableCell(withIdentifier: AddSubtaskButtonCell.identifier)!
            if let addSubtaskButtonCell = cell as? AddSubtaskButtonCell {
                addSubtaskButtonCell.subtaskTextField.delegate = self
            }
            
        case let addToMyDayCellValue as AddToMyDayCellValue:
            
            cell = buttonsTableView.dequeueReusableCell(withIdentifier: AddToMyDayButtonCell.identifier)!
            if let addToMyDayButtonCell = cell as? AddToMyDayButtonCell {
                addToMyDayButtonCell.isOn = addToMyDayCellValue.inMyDay
            }
        
        case _ as RemindCellValue:
            cell = buttonsTableView.dequeueReusableCell(withIdentifier: RemindButtonCell.identifier)!
            
        case _ as DeadlineCellValue:
            cell = buttonsTableView.dequeueReusableCell(withIdentifier: DeadlineButtonCell.identifier)!
            
        case _ as RepeatCellValue:
            cell = buttonsTableView.dequeueReusableCell(withIdentifier: RepeatButtonCell.identifier)!
            
        case _ as AddFileCellValue:
            cell = buttonsTableView.dequeueReusableCell(withIdentifier: AddFileButtonCell.identifier)!
        
        case let fileCellValue as FileCellValue:
            cell = buttonsTableView.dequeueReusableCell(withIdentifier: FileButtonCell.identifier)!
            if let fileButtonCell = cell as? FileButtonCell {
                fileButtonCell.fillFromCellValue(cellValue: fileCellValue)
                fileButtonCell.actionButton.addTarget(self, action: #selector(pressedFileDeleteTouchUpInside(sender:)), for: .touchUpInside)
            }
            
        case let descriprinCellValue as DescriptionCellValue:
            cell = buttonsTableView.dequeueReusableCell(withIdentifier: DescriptionButtonCell.identifier)!
            if let descriptionButtonCell = cell as? DescriptionButtonCell {
                descriptionButtonCell.mainTextLabel.attributedText = descriprinCellValue.text
            }
            
        default :
            cell = buttonsTableView.dequeueReusableCell(withIdentifier: TaskViewLabelsButtonCell.identifier)!
            if cell is TaskViewLabelsButtonCell {
//                buttonWithLabel.mainTextLabel.text = buttonValue.maintext
            }
        }
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {

    }
    
    
    // MARK: select row
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let cell = tableView.cellForRow(at: indexPath)
        let cellValue = buttonsArray[indexPath.row]
        
        
        switch cell {
        case let addSubtaskButton as AddSubtaskButtonCell :
            addSubtaskButton.subtaskTextField.becomeFirstResponder()
        
        case let addToMyDayButton as AddToMyDayButtonCell :
            task.isMyDay = !task.isMyDay
        
        case let remindButton as RemindButtonCell :
            setTaskReminder(remindButton)
            
        case _ as DeadlineButtonCell :
            presentTaskDeadlineViewController()
            
        case let repeatButton as RepeatButtonCell :
            // TODO: открывать контроллер с настройками повтора
            repeatButton.state = .defined
            
        case _ as AddFileButtonCell :
            showAddFileAlertController()
            
        case _ as FileButtonCell :
            // TODO: открыть контроллер и показать содержимое файла
            break
            
        case let descriptionButton as DescriptionButtonCell:
            let taskDescriptionController = TaskDescriptionViewController(task: task)
            taskDescriptionController.dismissDelegate = self
            
            present(taskDescriptionController, animated: true)
            
//            if descriptionButton.state == .empty {
//                descriptionButton.fillMainText(attributedText: NSAttributedString(string: "Первая строка текста\nВторая строка\nТретья строка текста\nЧетвертая строка текста\nПятая строка текста\nШестая строка текста\nСедьмая строка"))
//            } else if descriptionButton.state == .textFilled {
//                descriptionButton.fillMainText(attributedText: nil)
//            }
            
        default :
            break
        }
        
        tableView.deselectRow(at: indexPath, animated: false)
        
        // TODO: переделать обновление данных на более экономичный вариант
        fillButtonsArray(from: task)
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
        if buttonsArray[indexPath.row] is FileCellValue {
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
class TaskTitleTextViewDelegate: NSObject, UITextViewDelegate {
    private var textView: UITextView
    private var viewController: TaskViewController
    
    init(textView: UITextView, viewController: TaskViewController) {
        self.textView = textView
        self.viewController = viewController
    }
    
    func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
        if (text == "\n") {
            viewController.navigationController?.navigationBar.topItem?.setRightBarButton(nil, animated: true)
            textView.resignFirstResponder()
        }
        
        return true
    }
    
    func textViewShouldBeginEditing(_ textView: UITextView) -> Bool {
        viewController.showTaskTitleNavigationItemReady()
        
        return true
    }

    
    // TODO: заменять перевод строки на пробел
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


// MARK: description controller dismiss delegate
extension TaskViewController: TaskDescriptionViewControllerDelegate {
    func didDismissTaskDescriptionViewController(isSuccess: Bool) {
        fillControls(from: task)
    }
}

// MARK: temporary code
// TODO: удалить
extension TaskViewController {
    
    private func switchScreenIsVisible(_ isViewScreen: Bool) {
        let imageView = view.viewWithTag(777)
        if imageView == nil {
            screenImageView.frame = view.frame
            screenImageView.layer.zPosition = 10
            screenImageView.layer.opacity = 0.5
            
            view.addSubview(screenImageView)
        }
        
        screenImageView.isHidden = !isViewScreen
        screenOpacitySlider.isHidden = !isViewScreen
    }
    
    private func setupScreenVisibleControls() {
        // screenImageView
        screenImageView.tag = 777
        
        // screenIsVisibleSwitch
        screenIsVisibleSwitch.translatesAutoresizingMaskIntoConstraints = false
        
        screenIsVisibleSwitch.isOn = false
        screenIsVisibleSwitch.onTintColor = .systemOrange
        screenIsVisibleSwitch.thumbTintColor = .systemBlue
        screenIsVisibleSwitch.layer.zPosition = 11
        screenIsVisibleSwitch.isHidden = false // hidden
        
        screenIsVisibleSwitch.addTarget(self, action: #selector(taskDoneSwitchValueChange(tdSwitch: event:)), for: .valueChanged)
        
        // screenOpacitySlider
        screenOpacitySlider.translatesAutoresizingMaskIntoConstraints = false
        screenOpacitySlider.value = 30
        screenOpacitySlider.layer.zPosition = 11
        screenOpacitySlider.minimumValue = 0
        screenOpacitySlider.maximumValue = 100
        screenOpacitySlider.isHidden = true // hidden
        
        screenOpacitySlider.addTarget(self, action: #selector(screenOpacitySliderValueChange(slider:)), for: .valueChanged)
    }
    
    private func addConstraintScreenControls() {
        // screenIsVisibleSwitch
        NSLayoutConstraint.activate([
            screenIsVisibleSwitch.leftAnchor.constraint(equalTo: view.leftAnchor, constant: 20),
            screenIsVisibleSwitch.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor),
        ])

        // screenOpacitySlider
        NSLayoutConstraint.activate([
            screenOpacitySlider.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor),
            screenOpacitySlider.leftAnchor.constraint(equalTo: screenIsVisibleSwitch.rightAnchor, constant: 20),
            screenOpacitySlider.rightAnchor.constraint(equalTo: view.safeAreaLayoutGuide.rightAnchor, constant: -20),
        ])
    }

    private func addScreenControls() {
        view.addSubview(screenIsVisibleSwitch)
        view.addSubview(screenOpacitySlider)
    }
    
    @objc func taskDoneSwitchValueChange(tdSwitch: UISwitch, event: UIEvent) {
        switchScreenIsVisible(tdSwitch.isOn)
    }
    
    @objc func screenOpacitySliderValueChange(slider: UISlider) {
        screenImageView.layer.opacity =  slider.value / 100
    }
}
