
import UIKit

/// Контроллер редактирования описания задачи
class TaskDescriptionViewController: UIViewController {

    let taskEm = TaskEntityManager()
    
    lazy var navigationBar = UINavigationBar()
    lazy var descriptionTextView = UITextView()
    
    // MARK: toolbar controls
    lazy var toolbar = UIToolbar()
    lazy var boldBarButtonItem = UIBarButtonItem(title: "bold", style: .plain, target: nil, action: nil)
    
    var task: Task
    
    var dismissDelegate: TaskDescriptionViewControllerDelegate?
    
    
    // MARK: init
    init(task: Task) {
        self.task = task
        
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
    // MARK: lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()

        setupControls()
        addSubviews()
        setupConstraints()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        fillControlsFromTask()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        updateTask()
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        
        dismissDelegate?.didDisappearTaskDescriptionViewController(isSuccess: true)
    }
    
    
    // MARK: setup methods
    private func setupControls() {
        setupViewOfController()
        setupNavigationBar()
        setupTaskDescriptionTextView()
        setupToolbar()
    }
    
    private func setupViewOfController() {
        view.backgroundColor = InterfaceColors.white
    }
    
    private func setupNavigationBar() {
        navigationBar.translatesAutoresizingMaskIntoConstraints = false
        navigationBar.delegate = self
        
        navigationBar.backgroundColor = InterfaceColors.white
        navigationBar.isTranslucent = false
        navigationBar.layer.borderWidth = 0.5
        navigationBar.layer.borderColor = InterfaceColors.TaskDescriptionController.navBarSeparator.cgColor
        
        navigationBar.pushItem(navigationItem, animated: false)
    
        title = "Заметка"
        navigationBar.topItem?.prompt = task.title
        navigationBar.topItem?.rightBarButtonItem = UIBarButtonItem(title: "Готово", style: .done, target: self, action: #selector(readyEditTaskDescription))
    }
    
    private func setupTaskDescriptionTextView() {
        descriptionTextView.translatesAutoresizingMaskIntoConstraints = false
        descriptionTextView.delegate = self
        descriptionTextView.backgroundColor = InterfaceColors.white
        descriptionTextView.textColor = InterfaceColors.blackText
    }
    
    private func setupToolbar() {

        toolbar.sizeToFit()
        toolbar.backgroundColor = nil
        toolbar.isOpaque = true
        toolbar.isTranslucent = true
        
        
//        boldBarButtonItem.image = UIImage(systemName: "bold")
//        boldBarButtonItem.tintColor = InterfaceColors.textGray
//
//        toolbar.setItems([boldBarButtonItem], animated: false)
        
        descriptionTextView.inputAccessoryView = toolbar
    }
    
    private func addSubviews() {
        view.addSubview(navigationBar)
        view.addSubview(descriptionTextView)
    }
    
    private func setupConstraints() {
        // navigationBar
        NSLayoutConstraint.activate([
            navigationBar.topAnchor.constraint(equalTo: view.topAnchor, constant: -1),
            navigationBar.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: -1),
            navigationBar.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: 1),
        ])
        
        // descriptionTextView
        NSLayoutConstraint.activate([
            descriptionTextView.topAnchor.constraint(equalTo: navigationBar.bottomAnchor),
            descriptionTextView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor),
            descriptionTextView.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor),
            descriptionTextView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
        ])
    }
    
    
    // MARK: action-handlers
    @objc private func readyEditTaskDescription() {
        if descriptionTextView.isFirstResponder {
            descriptionTextView.resignFirstResponder()
        }
        
        dismiss(animated: true)
    }
    
    @objc private func switchBoldText() {
        
    }
    
    // MARK: work with model (task)
    private func updateTask() {
        // TODO: конвертировать из NSAttributedString в хранимый string
        taskEm.updateFields(
            taskDescription: descriptionTextView.attributedText.string,
            descriptionUpdatedAt: Date(),
            task: task
        )
    }
    
    private func fillControlsFromTask() {
        if let filledTaskDescription = task.taskDescription {
            // TODO: конвертировать нормально в NSAttributedString
            descriptionTextView.attributedText = NSAttributedString(string: filledTaskDescription)
        }
            
        descriptionTextView.font = UIFont.systemFont(ofSize: 18)
    }
    
}


// MARK: descriptionTextView delegate
extension TaskDescriptionViewController: UITextViewDelegate {
    func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
        
        return true
    }
    
    func textViewDidBeginEditing(_ textView: UITextView) {
    }
    
    func textViewDidEndEditing(_ textView: UITextView) {
    }
}


// MARK: NavigationBar delegate
extension TaskDescriptionViewController: UINavigationBarDelegate {
//    func position(for bar: UIBarPositioning) -> UIBarPosition {
//        return .topAttached
//    }
}


// MARK: dismiss protocol
protocol TaskDescriptionViewControllerDelegate {
    func didDisappearTaskDescriptionViewController(isSuccess: Bool)
}
