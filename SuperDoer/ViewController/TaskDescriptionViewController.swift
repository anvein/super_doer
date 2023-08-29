
import UIKit

/// Контроллер редактирования описания задачи
class TaskDescriptionViewController: UIViewController {

    lazy var navigationBar = UINavigationBar()
    lazy var descriptionTextView = UITextView()
    
    lazy var toolbar = UIToolbar()
    
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
        
        dismissDelegate?.didDismissTaskDescriptionViewController(isSuccess: true)
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
        navigationBar.topItem?.rightBarButtonItem = UIBarButtonItem(title: "Готово", style: .plain, target: self, action: #selector(readyEditTaskDescription))
    }
    
    private func setupTaskDescriptionTextView() {
        descriptionTextView.translatesAutoresizingMaskIntoConstraints = false
        descriptionTextView.delegate = self
        descriptionTextView.backgroundColor = InterfaceColors.white
        descriptionTextView.textColor = InterfaceColors.blackText
    }
    
    private func setupToolbar() {
        let buttonItem = UIBarButtonItem(title: "Полужирным", style: .plain, target: nil, action: nil)
        toolbar.setItems([buttonItem], animated: false)

        toolbar.sizeToFit()
        toolbar.backgroundColor = nil
        
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
        
        updateTask()
        dismiss(animated: true)
    }
    
    
    // MARK: work with model (task)
    private func updateTask() {
        let mutableTaskDescription = NSMutableAttributedString(attributedString: descriptionTextView.attributedText)
        mutableTaskDescription.addAttribute(
            .font,
            value: UIFont.systemFont(ofSize: 16),
            range: NSRange(location: 0, length: mutableTaskDescription.length)
        )
        
        task.description = mutableTaskDescription
    }
    
    private func fillControlsFromTask() {
        if let filledTaskDescription = task.description {
            let mutableTaskDescription = NSMutableAttributedString(attributedString: filledTaskDescription)
            mutableTaskDescription.addAttribute(
                .font,
                value: UIFont.systemFont(ofSize: 18),
                range: NSRange(location: 0, length: mutableTaskDescription.length)
            )
        
            descriptionTextView.attributedText = mutableTaskDescription
        }
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
    func didDismissTaskDescriptionViewController(isSuccess: Bool)
}
