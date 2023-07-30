
import UIKit

/// Экран списков
class HomeViewController: UIViewController, UIScrollViewDelegate {

    lazy var tasksListVC = TasksListViewController()
    var scrollView = UIScrollView()
    
    let containerView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        
        return view
    }()
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = UIColor(red: 213 / 255, green: 247 / 255, blue: 232 / 255, alpha: 1)
        
        self.title = "Списки"

        setupScrollView()
        buildButton()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        navigationController?.navigationBar.prefersLargeTitles = true
        
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)

        navigationController?.pushViewController(
            tasksListVC,
            animated: false
        )
    }
    
    private func buildButton() {
        
        let btnOpenTasksList = UIButton(type: .system)
        btnOpenTasksList.setTitle("Список задач", for: .normal)
        btnOpenTasksList.translatesAutoresizingMaskIntoConstraints = false
        
        scrollView.addSubview(btnOpenTasksList)
        
        NSLayoutConstraint.activate([
            btnOpenTasksList.widthAnchor.constraint(equalToConstant: 220),
            btnOpenTasksList.heightAnchor.constraint(equalToConstant: 45),
            btnOpenTasksList.topAnchor.constraint(equalTo: scrollView.topAnchor, constant: 300),
            btnOpenTasksList.centerXAnchor.constraint(equalTo: scrollView.centerXAnchor)
            
        ])
        
        btnOpenTasksList.addTarget(nil, action: #selector(openTaskList), for: .touchUpInside)
    }
    
    @objc private func openTaskList() {
        navigationController?.pushViewController(tasksListVC, animated: true)
    }

    private func setupScrollView() -> UIScrollView {
        scrollView.translatesAutoresizingMaskIntoConstraints = false
//        scrollView.backgroundColor = .systemTeal
        scrollView.delegate = self
        
        scrollView.showsVerticalScrollIndicator = true // default = true
        scrollView.alwaysBounceVertical = true // default = false, подпрыгивании при достижении конца скролла (?)
        scrollView.contentInsetAdjustmentBehavior = .never
        
        view.addSubview(scrollView)
        scrollView.addSubview(containerView)
        NSLayoutConstraint.activate([
            scrollView.leftAnchor.constraint(equalTo: view.leftAnchor, constant: 0),
            scrollView.rightAnchor.constraint(equalTo: view.rightAnchor, constant: 0),
            scrollView.topAnchor.constraint(equalTo: view.topAnchor, constant: 0),
            scrollView.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: 0)
        ])
        
        // container
        NSLayoutConstraint.activate([
            containerView.topAnchor.constraint(equalTo: scrollView.topAnchor, constant: 0),
            containerView.leadingAnchor.constraint(equalTo: scrollView.leadingAnchor, constant: 0),
            containerView.trailingAnchor.constraint(equalTo: scrollView.trailingAnchor, constant: 0),
            containerView.bottomAnchor.constraint(equalTo: scrollView.bottomAnchor),
            containerView.heightAnchor.constraint(equalToConstant: 1500),
        ])
        
        return scrollView
    }

}

