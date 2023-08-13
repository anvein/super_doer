
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
    let screenImageView = UIImageView(image: UIImage(named: "screen"))
    
    
    // MARK: model
    var task: Task
    
    var buttonsArray: [ButtonCellValueProtocol] = [
        AddSubTaskCellValue(),
        AddToMyDayCellValue(),
        RemindCellValue(),
        DeadlineCellValue(),
        RepeatCellValue(),
        AddFileCellValue(),
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
    }
    
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
    
    
    // MARK: controller handlers
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
    
    // MARK: notifications handler
    
    // MARK: other methods
    
    private func setBackButtonTitle() {
        navigationController?.navigationBar.backItem?.backBarButtonItem = UIBarButtonItem(
            title: navigationController?.navigationBar.backItem?.title,
            style: .plain,
            target: nil,
            action: nil
        )
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
//        
        view.addSubview(screenIsVisibleSwitch)
        view.addSubview(screenOpacitySlider)
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
    }
    
    private func setupViewOfController() {
        view.backgroundColor = .white
        
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
    
    
//    private func setupTaskTitleTextField() {
//        subtaskCreateTextField.translatesAutoresizingMaskIntoConstraints = false
//
//        subtaskCreateTextField.textColor = .systemBlue
//        subtaskCreateTextField.font = UIFont(name: "Arial", size: 26)
//                
//                
//        subtaskCreateTextField.placeholder = "Что нужно сделать?"
//
//        subtaskCreateTextField.text = "Сделать "
//
//        // стиль рамки
//        subtaskCreateTextField.borderStyle = .none
//        
//        subtaskCreateTextField.layer.borderWidth = 1
//        subtaskCreateTextField.layer.borderColor = CGColor(red: 191/255, green: 88/255, blue: 84/255, alpha: 1)
//                
//        // адаптировать размер шрифта, чтобы весь текст влазил
//        subtaskCreateTextField.adjustsFontSizeToFitWidth = true
//        subtaskCreateTextField.minimumFontSize = 1
//
//        subtaskCreateTextField.clearButtonMode = .always
//        
////        self.taskTitleTextFieldDelegate = OtherFieldDelegate(textField: subtaskCreateTextField)
////        subtaskCreateTextField.delegate = self.taskTitleTextFieldDelegate
//
//        
//        // разрешить форматирование текста
//        subtaskCreateTextField.allowsEditingTextAttributes = true
//        
//        subtaskCreateTextField.addTarget(self, action: #selector(someTextFieldEvent(sender:event:)), for: .valueChanged)
//    }
//    
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
            
            
        default :
            cell = buttonsTableView.dequeueReusableCell(withIdentifier: TaskViewLabelsButtonCell.identifier)!
            if let buttonWithLabel = cell as? TaskViewLabelsButtonCell {
                buttonWithLabel.mainTextLabel.text = "Нереализованный тип кнопки"
            }
        }
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
//        let cell = tableView.cellForRow(at: indexPath)
        
        // TODO: возвращает nil
//        if let taskViewButtonCell = cell as? TaskViewButtonCellProtocol {
//            return taskViewButtonCell.standartHeight.cgFloat
//        }
        if indexPath.row == 0 {
            return 68
        }
        
        return 58
    }
    
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {

    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let cell = tableView.cellForRow(at: indexPath)
        
        switch cell {
        case let addSubtaskButton as AddSubtaskButtonCell :
            addSubtaskButton.subtaskTextField.becomeFirstResponder()
        
        case let addToMyDayButton as AddToMyDayButtonCell :
            addToMyDayButton.isOn = !addToMyDayButton.isOn
        
        case let remindButton as RemindButtonCell :
            // TODO: открывать контроллер с выбором даты
            remindButton.state = .defined
            
        case let deadlineButton as DeadlineButtonCell :
            // TODO: открывать контроллер с выбором даты
            deadlineButton.state = .defined
            
        case let repeatButton as RepeatButtonCell :
            // TODO: открывать контроллер с настройками повтора
            repeatButton.state = .defined
            
        case let addFileButton as AddFileButtonCell :
            // TODO: открыть AlertController для выбора места откуда загружать файл
            break
            
        default :
            break
        }
        
        tableView.deselectRow(at: indexPath, animated: false)
    }
    
    
    
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
        
        screenIsVisibleSwitch.addTarget(self, action: #selector(taskDoneSwitchValueChange(tdSwitch: event:)), for: .valueChanged)
        
        // screenOpacitySlider
        screenOpacitySlider.translatesAutoresizingMaskIntoConstraints = false
        screenOpacitySlider.value = 30
        screenOpacitySlider.layer.zPosition = 11
        screenOpacitySlider.minimumValue = 0
        screenOpacitySlider.maximumValue = 100
        
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
    
    
    @objc func taskDoneSwitchValueChange(tdSwitch: UISwitch, event: UIEvent) {
        switchScreenIsVisible(tdSwitch.isOn)
    }
    
    @objc func screenOpacitySliderValueChange(slider: UISlider) {
        screenImageView.layer.opacity =  slider.value / 100
    }
}
