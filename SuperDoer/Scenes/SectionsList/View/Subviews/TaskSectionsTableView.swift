import UIKit

final class TaskSectionsTableView: UITableView {

    convenience init() {
        self.init(frame: .zero, style: .grouped)
    }

    override init(frame: CGRect, style: UITableView.Style) {
        super.init(frame: frame, style: style)

        translatesAutoresizingMaskIntoConstraints = false
        separatorStyle = .none
        backgroundColor = nil

        registerCell(TaskSectionTableCell.self)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

}
