
import UIKit

class TasksListTableView: UITableView {
    
    override init(frame: CGRect, style: UITableView.Style) {
        super.init(frame: frame, style: style)
        
        translatesAutoresizingMaskIntoConstraints = false
        
        // включено ли редактирование (кнопки минусов в таблице)
        // tasksTable.isEditing = true
        
        backgroundColor = nil
        scrollsToTop = true
        separatorStyle = .none
        layer.zPosition = 10
        
        
//        let tableTitleLabel = UILabel(frame: CGRect(x: 5, y: 5, width: 150, height: 50))
//        tableHeaderView = tableTitleLabel
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func setHeaderLabel(_ text: String?) {
        if let tableHeaderLabel = tableHeaderView as? UILabel {
            tableHeaderLabel.text = text
        }
    }
    
}
