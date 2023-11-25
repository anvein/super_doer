
import UIKit

/// Экран списков
class HomeViewController: UIViewController, UIScrollViewDelegate {

    lazy var tasksListVC = TasksListViewController()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = InterfaceColors.white
        
        navigationController?.navigationBar.prefersLargeTitles = true
        navigationItem.largeTitleDisplayMode = .never
        title = "Списки"

        buildButton()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)

        navigationController?.pushViewController(
            tasksListVC,
            animated: false
        )
    }
    
    private func buildButton() {
        let btnOpenTasksList = UIButton()
        btnOpenTasksList.setTitle("Список задач", for: .normal)
        btnOpenTasksList.setTitleColor(.systemBlue, for: .normal)
        btnOpenTasksList.translatesAutoresizingMaskIntoConstraints = false

        view.addSubview(btnOpenTasksList)
        
        NSLayoutConstraint.activate([
            btnOpenTasksList.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            btnOpenTasksList.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            btnOpenTasksList.widthAnchor.constraint(equalToConstant: 220),
            btnOpenTasksList.heightAnchor.constraint(equalToConstant: 45),
        ])

        btnOpenTasksList.addTarget(nil, action: #selector(openTaskList), for: .touchUpInside)
    }

    @objc private func openTaskList() {
        navigationController?.pushViewController(tasksListVC, animated: true)
    }

}





//import UIKit
//
///// Экран списков
//class HomeViewController: UIViewController, UIScrollViewDelegate {
//
//    lazy var tasksListVC = TasksListViewController()
//    
//    var taskSectionsTableView = UITableView(frame: .zero, style: .grouped)
//    
//    override func viewDidLoad() {
//        super.viewDidLoad()
//        
//        navigationController?.navigationBar.prefersLargeTitles = true
//        navigationItem.largeTitleDisplayMode = .never
//        title = "Списки"
//        
//        setupControls()
//        addSubviewsToMainView()
//        setupConstraints()
//    }
//    
//    
//
//
//}
//
//
//// MARK: LAYOUT
//extension HomeViewController {
//    private func addSubviewsToMainView() {
//        
//    }
//    
//    private func setupControls() {
//        setupViewOfViewController()
//    }
//    
//    private func setupConstraints() {
//        
//    }
//    
//    private func setupViewOfViewController() {
//        view.backgroundColor = InterfaceColors.white
//    }
//}
