
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
    
    
//    var taskTitleTextFieldDelegate: OtherFieldDelegate?
    
    lazy var subtaskCreateTextField = UITextField()
    
    lazy var taskDeleteButton = UIButton()
    
    /// Редактируемое в данный момент поле TextField
    var textFieldEditing: UITextField?
    
    // TODO: temp controls
    var isViewScreen = true
    lazy var screenIsVisibleSwitch = UISwitch()
    lazy var screenOpacitySlider = UISlider()
    let screenImageView = UIImageView(image: UIImage(named: "screen3"))
    
    
    // MARK: model
    var task: Task
    
    var buttonsArray: [ButtonCellValueProtocol] = [
        AddSubTaskCellValue(),
        AddToMyDayCellValue(),
        RemindCellValue(),
        DeadlineCellValue(),
        RepeatCellValue(),
        FileCellValue(fileExtension: "fga", fileName: "marcedes cla.fga", fileSize: "2,5 МБ"),
        FileCellValue(fileExtension: "mov", fileName: "Видео из файла 13.08.2023, 22.38 в 12342314", fileSize: "1.7 МБ"),
        AddFileCellValue(),
        DescriptionCellValue(text: "Текст описания задачи\nВторая строка описания\nТретья", dateUpdated: "Обновлено: несколько минут назад")
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
        addConstraints()
        
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
        
        showDeleteFileAlertController(fileIndexPath: indexPath)
    }
    
    // MARK: method handlers
    
    private func setReminder(_ remindButton: RemindButtonCell) {
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
    
    private func showDeleteFileAlertController(fileIndexPath indexPath: IndexPath) {
        let fileDeleteAlert = FileDeleteAlertController(fileIndexPath: indexPath) { indexPath in
            self.deleteFile(fileCellIndexPath: indexPath)
        }
        
        self.present(fileDeleteAlert, animated: true)
    }
    
    private func deleteFile(fileCellIndexPath indexPath: IndexPath) {
        buttonsArray.remove(at: indexPath.row)
        buttonsTableView.deleteRows(at: [indexPath], with: .fade)
    }
    
    private func showAddFileAlertController() {
        let addFileAlertController = AddFileAlertController(taskViewController: self)
        
        present(addFileAlertController, animated: true)
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
    
    private func addConstraints() {
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
        
//        setupTaskTitleTextField()
        setupTaskDeleteButton()
        
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
    
    private func setupTaskDeleteButton() {
        
        taskDeleteButton.translatesAutoresizingMaskIntoConstraints = false
        
        taskDeleteButton.layer.backgroundColor = CGColor.init(red: 0.7, green: 0.7, blue: 0.4, alpha: 1) // можно через layer задать bg
        
        
        
        
        
        taskDeleteButton.setTitle("default", for: .normal)
//        btn.setTitleColor(.yellow, for: .normal)
        
        taskDeleteButton.setImage(UIImage.init(systemName: "circle"), for: .normal)
        taskDeleteButton.setBackgroundImage(UIImage.init(named: "bg"), for: .normal)
        
        
//        UIButton

        
        
        
        taskDeleteButton.toolTip = "Подсказка" // на iOS не работает, мб только для voice over
        taskDeleteButton.tintColor = .red // get + set (применяется к заголовку и изображению)
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
            
        case _ as AddToMyDayCellValue:
            cell = buttonsTableView.dequeueReusableCell(withIdentifier: AddToMyDayButtonCell.identifier)!
        
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
            
        case _ as DescriptionCellValue:
            cell = buttonsTableView.dequeueReusableCell(withIdentifier: DescriptionButtonCell.identifier)!
            
            
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
        
        switch cell {
        case let addSubtaskButton as AddSubtaskButtonCell :
            addSubtaskButton.subtaskTextField.becomeFirstResponder()
        
        case let addToMyDayButton as AddToMyDayButtonCell :
            addToMyDayButton.isOn = !addToMyDayButton.isOn
        
        case let remindButton as RemindButtonCell :
            setReminder(remindButton)
            
        case let deadlineButton as DeadlineButtonCell :
            // TODO: открывать контроллер с выбором даты
            deadlineButton.state = .defined
            
        case let repeatButton as RepeatButtonCell :
            // TODO: открывать контроллер с настройками повтора
            repeatButton.state = .defined
            
        case _ as AddFileButtonCell :
            showAddFileAlertController()
            
        case _ as FileButtonCell :
            // TODO: открыть контроллер и показать содержимое файла
            break
            
        case let descriptionButton as DescriptionButtonCell:
            if descriptionButton.state == .empty {
                descriptionButton.fillMainText(attributedText: NSAttributedString(string: "Первая строка текста\nВторая строка\nТретья строка текста\nЧетвертая строка текста\nПятая строка текста\nШестая строка текста\nСедьмая строка"))
            } else if descriptionButton.state == .textFilled {
                descriptionButton.fillMainText(attributedText: nil)
            }
            
        default :
            break
        }
        
        
//        switch cellState {
//        case 0 :
//            cell?.textLabel?.text = nil
//            cell?.detailTextLabel?.text = nil
//        case 1:
//            cell?.textLabel?.text = "textLabel"
//            cell?.detailTextLabel?.text = nil
//        case 2:
//            cell?.textLabel?.text = "textLabel"
//            cell?.detailTextLabel?.text = "detailTextLabel"
//        case 3:
//            cell?.textLabel?.text = nil
//            cell?.detailTextLabel?.text = "detailTextLabel"
//        case 4:
//            cell?.textLabel?.text = "textLabel"
//            cell?.detailTextLabel?.text = "detailTextLabel"
//        default:
//            break
//        }
//
//
//        cellState = cellState == 4 ? 0 : cellState + 1
//
        
        tableView.deselectRow(at: indexPath, animated: false)
    }
    
    
    // MARK: swipes for row
    func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        let deleteAction = UIContextualAction(style: .destructive, title: nil) { deleteAction, view, completionHandler in
            self.showDeleteFileAlertController(fileIndexPath: indexPath)
            
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
        screenIsVisibleSwitch.isHidden = true // hidden
        
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
            screenIsVisibleSwitch.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -30),
        ])

        // screenOpacitySlider
        NSLayoutConstraint.activate([
            screenOpacitySlider.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -30),
            screenOpacitySlider.leftAnchor.constraint(equalTo: screenIsVisibleSwitch.rightAnchor, constant: 10),
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
