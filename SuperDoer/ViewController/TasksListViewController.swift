
import UIKit

/// Контроллер списка задач
class TasksListViewController: UIViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        self.title = "Задачи на неделю" // TODO: брать из названия конкретного списка
        
        
        view.backgroundColor = .systemGray5
    
        
        buildButton()
        
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
//        navigationController?.isNavigationBarHidden = true
        navigationController?.navigationBar.prefersLargeTitles = false
    
        
        
        
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)

    }
    
    private func buildButton() {
        
        let btnOpenTasksView = UIButton(type: .system)
        btnOpenTasksView.setTitle("Детальная задачи", for: .normal)
        btnOpenTasksView.translatesAutoresizingMaskIntoConstraints = false
        
        self.view.addSubview(btnOpenTasksView)
        
        NSLayoutConstraint.activate([
            btnOpenTasksView.widthAnchor.constraint(equalToConstant: 220),
            btnOpenTasksView.heightAnchor.constraint(equalToConstant: 45),
            btnOpenTasksView.topAnchor.constraint(equalTo: self.view.topAnchor, constant: 300),
            btnOpenTasksView.centerXAnchor.constraint(equalTo: self.view.centerXAnchor)
            
        ])
        
        btnOpenTasksView.addTarget(nil, action: #selector(openTaskView), for: .touchUpInside)
    }
    
    @objc func openTaskView() {
        let taskVC = TaskViewController()
        taskVC.view.backgroundColor = .systemTeal
        
        self.navigationController?.pushViewController(taskVC, animated: true)
    }

}


