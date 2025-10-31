import UIKit
import RxSwift

class TextEditorViewController: UIViewController {

    private var viewModel: TextEditorViewModelType

    private let disposeBag = DisposeBag()

    // MARK: - Subviews

    private let navigationBar = UINavigationBar()
    private let textView = UITextView()

    private var readyBarButton: UIBarButtonItem?

    private let toolbar = UIToolbar()
    private let boldBarButtonItem = UIBarButtonItem(title: "bold", style: .plain, target: nil, action: nil)

    // MARK: - Init

    init(viewModel: TextEditorViewModel) {
        self.viewModel = viewModel
        
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()

        setupView()
        setupHierarchy()
        setupConstraints()
        setupBindings()
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)

        if isBeingDismissed || isMovingFromParent {
            viewModel.didCloseRelay.accept(())
        }
    }
    
}

private extension TextEditorViewController {
    // MARK: - Setup

    func setupView() {
        view.backgroundColor = .Common.white

        setupNavigationBar()
        setupTaskDescriptionTextView()
        setupToolbar()
    }

    func setupNavigationBar() {
        navigationBar.translatesAutoresizingMaskIntoConstraints = false
        navigationBar.delegate = self
        
        navigationBar.backgroundColor = .Common.white
        navigationBar.isTranslucent = false
        navigationBar.layer.borderWidth = 0.5
        navigationBar.layer.borderColor = UIColor.TaskDescription.navBarSeparator.cgColor

        navigationBar.pushItem(navigationItem, animated: false)

        let readyBarButton = UIBarButtonItem(title: "Готово", style: .done, target: nil, action: nil)
        navigationBar.topItem?.rightBarButtonItem = readyBarButton
        self.readyBarButton = readyBarButton
    }
    
    func setupTaskDescriptionTextView() {
        textView.translatesAutoresizingMaskIntoConstraints = false
        textView.delegate = self
        textView.backgroundColor = .Common.white
        textView.textColor = .Text.black
        textView.font = UIFont.systemFont(ofSize: 18)
    }
    
    func setupToolbar() {

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
    
    func setupHierarchy() {
        view.addSubview(navigationBar)
        view.addSubview(textView)
    }
    
    func setupConstraints() {
        NSLayoutConstraint.activate([
            navigationBar.topAnchor.constraint(equalTo: view.topAnchor, constant: -1),
            navigationBar.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: -1),
            navigationBar.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: 1),
        ])

        NSLayoutConstraint.activate([
            textView.topAnchor.constraint(equalTo: navigationBar.bottomAnchor),
            textView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor),
            textView.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor),
            textView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
        ])
    }
    
    func setupBindings() {
        // VM -> V
        viewModel.titleDriver.drive(onNext: { [weak self] value in
            self?.title = value
        })
        .disposed(by: disposeBag)

        viewModel.subtitleDriver.drive(onNext: { [weak self] value in
            self?.navigationBar.topItem?.prompt = value
        })
        .disposed(by: disposeBag)

        viewModel.textRelay
            .asDriver()
            .distinctUntilChanged()
            .drive(textView.rx.attributedText)
            .disposed(by: disposeBag)

        // V -> VM
        textView.rx.attributedText
            .distinctUntilChanged()
            .bind(to: viewModel.textRelay)
            .disposed(by: disposeBag)

        // internal
        readyBarButton?.rx.tap
            .subscribe { [weak self] _ in
                self?.handleTapReadyButton()
            }
            .disposed(by: disposeBag)

    }

    // MARK: - Actions handlers

    func handleTapReadyButton() {
        if textView.isFirstResponder {
            textView.resignFirstResponder()
        }

        dismiss(animated: true)
    }
    
}

// MARK: - UITextViewDelegate

extension TextEditorViewController: UITextViewDelegate {
    func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
        return true
    }
    
    func textViewDidBeginEditing(_ textView: UITextView) {
    }
    
    func textViewDidEndEditing(_ textView: UITextView) {
    }
}


// MARK: - UINavigationBarDelegate

extension TextEditorViewController: UINavigationBarDelegate {
//    func position(for bar: UIBarPositioning) -> UIBarPosition {
//        return .topAttached
//    }
}
