
import UIKit

/// Контроллер задачи
class TaskViewController: UIViewController {
    
    // MARK: controls
    lazy var taskDoneButton = CheckboxButton()
    
    lazy var taskTitleTextView = UITextView()
    var taskTitleTextViewDelegate: TaskTitleTextViewDelegate?
    
    lazy var isPriorityButton = StarButton()
    
    
    lazy var stubButtonView = {
        let btn = AddToMyDayComponent()
        
        return btn
    }()
    
    
    lazy var addToMyDayButtonView = AddToMyDayComponent()
    
    
    lazy var prioritySlider = UISlider()
    
    lazy var segmentedControl = UISegmentedControl()
    lazy var priorityLabel = UILabel()
    
    var taskTitleTextFieldDelegate: OtherFieldDelegate?
    
    lazy var subtaskCreateTextField = UITextField()
    
    lazy var taskDeleteButton = UIButton()
    
    // TODO: временный код
    var isViewScreen = true
    lazy var screenIsVisibleSwitch = UISwitch()
    lazy var screenOpacitySlider = UISlider()
    let screenImageView = UIImageView(image: UIImage(named: "screen"))
    
    // MARK: model
    var task: Task
    
    // MARD: init
    init() {
        task = Task()
        
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: life cycle methods
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupLayout()
        addSubviews()
        addConstraints()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        navigationController?.navigationBar.prefersLargeTitles = false // во viewWillAppear
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        setBackButtonTitle()
    }
    
    
    // MARK: target-action handlers
    @objc func segmentedControlValueChanged(sender: UISegmentedControl, event: UIEvent) {
        if let segmentTitle = segmentedControl.titleForSegment(at: sender.selectedSegmentIndex) {
            
            if segmentTitle == "Список" {
                subtaskCreateTextField.becomeFirstResponder()
            } else if segmentTitle == "title" {
                subtaskCreateTextField.resignFirstResponder()
            }
            print(segmentTitle)
        }

    }
    
    @objc func prioritySliderValueChanged(slider: UISlider, event: UIEvent) {
        let roundedValue = Int(round(slider.value))
        // устанавливает текст без форматирования
        priorityLabel.text = formatStringOfPriority(Float(roundedValue))
        
        
        priorityLabel.sizeToFit()
        
//        // видимо можно так сделать текст с форматированием
//        let attributedText = NSAttributedString()
//        attributedText.string // получить текст
//        attributedText.length // длина текста
//
//
//
//
//        // установить стилизованный текст
//        priorityLabel.attributedText = attributedText
        
        slider.setValue(Float(roundedValue), animated: false)
    }
    
    
    // MARK: notifications handler
    
    // MARK: other methods
    private func formatStringOfPriority(_ value: Float) -> String {
        return "Приоритет: \(Int(value.round(digits: 0) ?? 1))"
    }
    
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
extension TaskViewController {
    
    // MARK: add subviews & constraints
    private func addSubviews() {
        view.addSubview(taskDoneButton)
        view.addSubview(taskTitleTextView)
        view.addSubview(isPriorityButton)
        
        view.addSubview(stubButtonView)
        
        view.addSubview(addToMyDayButtonView)
        
        
//        view.addSubview(prioritySlider)
//        
//        view.addSubview(segmentedControl)
//        view.addSubview(priorityLabel)
//        
//        view.addSubview(subtaskCreateTextField)
//        view.addSubview(taskDeleteButton)
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
            taskTitleTextView.rightAnchor.constraint(equalTo: isPriorityButton.leftAnchor, constant: -10),
            taskTitleTextView.heightAnchor.constraint(greaterThanOrEqualToConstant: 45)
        ])
        
        // isPriorityButton
        NSLayoutConstraint.activate([
            isPriorityButton.topAnchor.constraint(equalTo: taskTitleTextView.topAnchor, constant: 6),
            isPriorityButton.rightAnchor.constraint(equalTo: view.safeAreaLayoutGuide.rightAnchor, constant: -12),
        ])
        
        
        // stubButtonView
        NSLayoutConstraint.activate([
            stubButtonView.topAnchor.constraint(equalTo: taskTitleTextView.bottomAnchor),
            stubButtonView.heightAnchor.constraint(equalToConstant: 68),
            stubButtonView.leftAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leftAnchor),
            stubButtonView.rightAnchor.constraint(equalTo: view.safeAreaLayoutGuide.rightAnchor),
        ])
        
        // addToMyDayButtonView
        NSLayoutConstraint.activate([
            addToMyDayButtonView.topAnchor.constraint(equalTo: stubButtonView.bottomAnchor),
            addToMyDayButtonView.heightAnchor.constraint(equalToConstant: 58),
            addToMyDayButtonView.leftAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leftAnchor),
            addToMyDayButtonView.rightAnchor.constraint(equalTo: view.safeAreaLayoutGuide.rightAnchor),
        ])

        
    
        
//        // prioritySlider
//        NSLayoutConstraint.activate([
//            prioritySlider.topAnchor.constraint(equalTo: taskTitleTextView.bottomAnchor, constant: 30),
//            prioritySlider.widthAnchor.constraint(equalTo: view.widthAnchor, multiplier: 0.85),
//            prioritySlider.centerXAnchor.constraint(equalTo: view.centerXAnchor),
//        ])
//
//        // priorityLabel
//        NSLayoutConstraint.activate([
//            priorityLabel.topAnchor.constraint(equalTo: prioritySlider.bottomAnchor, constant: 25),
//            priorityLabel.leftAnchor.constraint(equalTo: view.leftAnchor, constant: 20),
//            priorityLabel.rightAnchor.constraint(equalTo: view.rightAnchor, constant: -20)
//        ])
//
//        // segmentedControl
//        NSLayoutConstraint.activate([
//            segmentedControl.topAnchor.constraint(equalTo: priorityLabel.bottomAnchor, constant: 30),
//            segmentedControl.centerXAnchor.constraint(equalTo: view.centerXAnchor),
//        ])
//
//        // subtaskCreateTextField
//        NSLayoutConstraint.activate([
//            subtaskCreateTextField.topAnchor.constraint(equalTo: segmentedControl.bottomAnchor, constant: 25),
//            subtaskCreateTextField.leftAnchor.constraint(equalTo: view.leftAnchor, constant: 20),
//            subtaskCreateTextField.rightAnchor.constraint(equalTo: view.rightAnchor, constant: -20),
//            subtaskCreateTextField.heightAnchor.constraint(greaterThanOrEqualToConstant: 45)
//        ])
//
//        // taskDeleteButton
//        NSLayoutConstraint.activate([
//            taskDeleteButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -20),
//            taskDeleteButton.centerXAnchor.constraint(equalTo: view.centerXAnchor),
//            taskDeleteButton.heightAnchor.constraint(equalToConstant: 45),
//            taskDeleteButton.widthAnchor.constraint(equalToConstant: 200)
//        ])
        
        addConstraintScreenControls()
    }
    
    
    // MARK: setup controls methods (of instance)
    private func setupLayout() {
        setupViewOfController()
        
        setupTaskDoneButton()
        setupTaskTitleTextView()
        setupIsPriorityButton()
        
        setupTaskTitleTextField()
        setupPrioritySlider()
        setupSegmentedControl()
        setupPriorityLabel()
        
        setupTaskDeleteButton()
        
        setupScreenVisibleControls()
    }
    
    private func setupViewOfController() {
        view.backgroundColor = .white
        
        // TODO: удалить
        switchScreenIsVisible(false)
    }
    
    
    private func setupTaskDoneButton() {
        // TODO: удалить или наполнить
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
        
        taskTitleTextView.text = "🏡 Заказать полочку и повесить"
    }
    
    private func setupIsPriorityButton() {
        // TODO: удалить или наполнить
    }
    
    
    private func setupAddToMyDayButton() {
        addToMyDayButtonView.translatesAutoresizingMaskIntoConstraints = false
    }
    
    
    private func setupPrioritySlider() {
        prioritySlider.translatesAutoresizingMaskIntoConstraints = false
        
        prioritySlider.addTarget(self, action: #selector(prioritySliderValueChanged(slider: event:)), for: .valueChanged)
        
        // сделать, чтобы слайдер отправлял события только когда пользователь отпускает
        // default = true (отправляет непрерывно)
        // Сделать прилипание к шагам
        prioritySlider.isContinuous = true
        
        
        prioritySlider.minimumValue = 1
        prioritySlider.maximumValue = 3
        
        
        // цвет ползунка
        prioritySlider.thumbTintColor = .systemGreen
        
        // цвет полоски слева от ползунка
        prioritySlider.minimumTrackTintColor = .systemBlue
        
        // цвет полоски справа от ползунка
        prioritySlider.maximumTrackTintColor = .lightGray
        
        // цвет, который влияет на цвет картинок (min, max) и мб что-то еще
        prioritySlider.tintColor = .systemRed
        
        
        
        prioritySlider.minimumValueImage = UIImage(systemName: "star")?.withTintColor(.systemTeal).withRenderingMode(.alwaysOriginal)
        prioritySlider.maximumValueImage = UIImage(systemName: "star.circle")?.withTintColor(.systemRed, renderingMode: .alwaysOriginal)
        
        // картинка ползунка
        prioritySlider.setThumbImage(UIImage(systemName: "star.fill"), for: .normal) // во время, когда слайдер не трогают
        prioritySlider.setThumbImage(UIImage(systemName: "star.fill"), for: .highlighted) // во время перемещения сладйдера
        
        // устанавливает новое текущее значение
        prioritySlider.setValue(1, animated: true)
    }
    
    private func setupSegmentedControl() {
        segmentedControl.translatesAutoresizingMaskIntoConstraints = false
        
        // добавление таба с заголовком
        segmentedControl.insertSegment(withTitle: "Список", at: 0, animated: false)
        
        // Добавление сегмента с картинкой
        segmentedControl.insertSegment(with: UIImage(systemName: "face.smiling"), at: 1, animated: false)
        segmentedControl.setTitle("title", forSegmentAt: 1)
        
        // Добавление сегмента с обработчиком
        segmentedControl.insertSegment(
            action: UIAction(
                title: "Календарь",
                subtitle: "📆",
                handler: { _ -> () in print("Выбран сегмент \"Календарь\"") }
            ),
            at: 2,
            animated: false
        )
        
        // выбрать сегмент с индексом
        segmentedControl.selectedSegmentIndex = 2
        
        
        segmentedControl.addTarget(self, action: #selector(segmentedControlValueChanged(sender: event:)), for: .valueChanged)
        
//        // чет ни на что не влияет
//        segmentedControl.tintColor = .systemOrange
//
//        // цвет заливки курсора у выделенного элемента
//        segmentedControl.selectedSegmentTintColor = .systemOrange
//
//        // цвет фона (подложки)
//        segmentedControl.backgroundColor = .systemRed
    
        
    }
    
    private func setupPriorityLabel() {
        priorityLabel.translatesAutoresizingMaskIntoConstraints = false
        
        // цвет текста
        priorityLabel.textColor = .systemOrange
        
        // шрифт и размер (❓  какие шрифты можно использовать в приложении)
        priorityLabel.font = UIFont(name: "Futura", size: 30)
        
        // выравнивание текста
        priorityLabel.textAlignment = .center
        
        // кол-во строк (default = 1)
        // если установить 0, то будет бесконечно
        // если установить меньше строк, чем есть текста, то текст обрежется (зависит от lineBreakMode)
        // sizeToFit() опирается на это поле
//        priorityLabel.numberOfLines = 2
        
        // способ обрезки ("сокращения") текста (default = .byTruncatingTail)
        // чето указанный способ не сработал ❓
//        priorityLabel.lineBreakMode = .byTruncatingMiddle
        
//        priorityLabel.isUserInteractionEnabled = true
        
        // подгоняет размер шрифта под допустимую ширину
        // чтобы влазил весь контент
//        priorityLabel.adjustsFontSizeToFitWidth = true
        
        // минимальная % на который будет изменен текст при adjustsFontSizeToFitWidth
        // (если 1, то изменения размера не будет)
//        priorityLabel.minimumScaleFactor = 1
        
//        priorityLabel.isEnabled = true
        
        // тень, которая повторяет текст без размытия
        priorityLabel.shadowColor = .cyan
        priorityLabel.shadowOffset = CGSize(width: 10, height: 5)
        
        
        
        
        priorityLabel.text = formatStringOfPriority(prioritySlider.value)
    }
    
    private func setupTaskTitleTextField() {
        subtaskCreateTextField.translatesAutoresizingMaskIntoConstraints = false

        subtaskCreateTextField.textColor = .systemBlue
        subtaskCreateTextField.font = UIFont(name: "Arial", size: 26)
                
                
        subtaskCreateTextField.placeholder = "Что нужно сделать?"

        subtaskCreateTextField.text = "Сделать "

        // стиль рамки
        subtaskCreateTextField.borderStyle = .none
        
        subtaskCreateTextField.layer.borderWidth = 1
        subtaskCreateTextField.layer.borderColor = CGColor(red: 191/255, green: 88/255, blue: 84/255, alpha: 1)
                
        // адаптировать размер шрифта, чтобы весь текст влазил
        subtaskCreateTextField.adjustsFontSizeToFitWidth = true
        subtaskCreateTextField.minimumFontSize = 1

        subtaskCreateTextField.clearButtonMode = .always
        
        self.taskTitleTextFieldDelegate = OtherFieldDelegate(textField: subtaskCreateTextField)
        subtaskCreateTextField.delegate = self.taskTitleTextFieldDelegate

        
        // разрешить форматирование текста
        subtaskCreateTextField.allowsEditingTextAttributes = true
        
        subtaskCreateTextField.addTarget(self, action: #selector(someTextFieldEvent(sender:event:)), for: .valueChanged)
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
    
    
    @objc func buttonMenuAction1(_: Int) {
        print("Пункт меню 1")
    }
    
    
    // MARK: handlers
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
        navigationController?.navigationBar.topItem?.setRightBarButton(nil, animated: true)
        taskTitleTextView.resignFirstResponder()
    }
}



// MARK: делегаты
/// Делегат TextField
class OtherFieldDelegate: NSObject, UITextFieldDelegate {
    var textField: UITextField
    
    init(textField: UITextField) {
        self.textField = textField
    }

    // вызывается при нажатии "return"
    // чет true / false ни на что не влияют (или на отправку нотификации?)
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        print("textFieldShouldReturn")
        textField.resignFirstResponder()

        return true
    }
}

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

// MARK: model
struct Task {
    var title: String?
    var isDone: Bool = false
    
    var isPriority: Bool = false
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
