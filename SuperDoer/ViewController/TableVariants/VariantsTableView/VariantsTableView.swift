
import UIKit

/// Таблица с вариантами чего либо
class VariantsTableView: UITableView {
    
    convenience init() {
        self.init(frame: .zero, style: .plain)
    }
    
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
        
        register(VariantTableViewCell.self, forCellReuseIdentifier: VariantTableViewCell.identifier)
    }
}
