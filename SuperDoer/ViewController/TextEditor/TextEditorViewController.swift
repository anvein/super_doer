
import UIKit

/// Контроллер редактирования и форматирования "текста"
class TextEditorViewController: UIViewController {
    
    private weak var coordinator: TextEditorViewControllerCoordinator?
    private var viewModel: TextEditorViewModelType
    
    
    // MARK: controls
    private lazy var navigationBar = UINavigationBar()
    private lazy var textView = UITextView()
    
    
    // MARK: toolbar controls
    private lazy var toolbar = UIToolbar()
    private lazy var boldBarButtonItem = UIBarButtonItem(title: "bold", style: .plain, target: nil, action: nil)
    
    
    // MARK: init
    init(
        coordinator: TextEditorViewControllerCoordinator,
        viewModel: TaskDescriptionEditorViewModel
    ) {
        self.coordinator = coordinator
        self.viewModel = viewModel
        
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
        setupBindings()
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        
        coordinator?.didDisappearTextEditorViewController(
            text: textView.attributedText,
            isSuccess: true
        )
    }
    
    
    // MARK: action-handlers
    @objc private func readyEditTaskDescription() {
        if textView.isFirstResponder {
            textView.resignFirstResponder()
        }
        
        dismiss(animated: true)
    }
    
    @objc private func switchBoldText() {
        
    }
    
}


// MARK: - setup and layout
extension TextEditorViewController {
    private func setupControls() {
        setupViewOfController()
        setupNavigationBar()
        setupTaskDescriptionTextView()
        setupToolbar()
    }
    
    private func setupViewOfController() {
        view.backgroundColor = .Common.white
    }
    
    private func setupNavigationBar() {
        navigationBar.translatesAutoresizingMaskIntoConstraints = false
        navigationBar.delegate = self
        
        navigationBar.backgroundColor = .Common.white
        navigationBar.isTranslucent = false
        navigationBar.layer.borderWidth = 0.5
        navigationBar.layer.borderColor = UIColor.TaskDescription.navBarSeparator.cgColor

        navigationBar.pushItem(navigationItem, animated: false)
    
        title = "Заметка"
        navigationBar.topItem?.prompt = viewModel.title
        navigationBar.topItem?.rightBarButtonItem = UIBarButtonItem(
            title: "Готово",
            style: .done,
            target: self,
            action: #selector(readyEditTaskDescription)
        )
    }
    
    private func setupTaskDescriptionTextView() {
        textView.translatesAutoresizingMaskIntoConstraints = false
        textView.delegate = self
        textView.backgroundColor = .Common.white
        textView.textColor = .Text.black
    }
    
    private func setupToolbar() {

        toolbar.sizeToFit()
        toolbar.backgroundColor = nil
        toolbar.isOpaque = true
        toolbar.isTranslucent = true
        
        
//        boldBarButtonItem.image = UIImage(systemName: "bold")
//        boldBarButtonItem.tintColor = .Text.gray
//
//        toolbar.setItems([boldBarButtonItem], animated: false)
        
        textView.inputAccessoryView = toolbar
    }
    
    private func addSubviews() {
        view.addSubview(navigationBar)
        view.addSubview(textView)
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
            textView.topAnchor.constraint(equalTo: navigationBar.bottomAnchor),
            textView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor),
            textView.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor),
            textView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
        ])
    }
    
    private func setupBindings() {
        viewModel.textObservable.bindAndUpdateValue { [weak self] mutableAttrString in
            self?.textView.attributedText = mutableAttrString
            self?.textView.font = UIFont.systemFont(ofSize: 18)
        }
    }
}


// MARK: - descriptionTextView delegate
extension TextEditorViewController: UITextViewDelegate {
    func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
        
        return true
    }
    
    func textViewDidBeginEditing(_ textView: UITextView) {
    }
    
    func textViewDidEndEditing(_ textView: UITextView) {
    }
}


// MARK: - NavigationBar delegate
extension TextEditorViewController: UINavigationBarDelegate {
//    func position(for bar: UIBarPositioning) -> UIBarPosition {
//        return .topAttached
//    }
}


// MARK: - coordinator protocol for TextEditorViewController
protocol TextEditorViewControllerCoordinator: AnyObject {
    /// Контроллер редактирования текста был закрыт
    /// - Parameters:
    ///   - text: текст, который был на момент закрытия контроллера в TextView
    ///   - isSuccess: хз зачем этот параметр (в каком случае может быть isSuccess = false?)
    func didDisappearTextEditorViewController(text: NSAttributedString, isSuccess: Bool)
}
