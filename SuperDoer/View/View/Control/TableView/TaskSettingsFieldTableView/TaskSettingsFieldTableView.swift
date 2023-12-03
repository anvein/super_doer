
import UIKit

class TaskSettingsFieldTableView: UITableView {
    
    // MARK: init
    override init(frame: CGRect, style: UITableView.Style) {
        super.init(frame: frame, style: style)
        
        setup()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
    // MARK: setup methods
    private func setup() {
        translatesAutoresizingMaskIntoConstraints = false
        separatorStyle = .none
        backgroundColor = nil
        rowHeight = 50
        
        register(TaskSettingsFieldTableViewCell.self, forCellReuseIdentifier: TaskSettingsFieldTableViewCell.identifier)
    }
}
