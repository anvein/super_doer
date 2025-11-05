import UIKit

extension UITableView {
    func registerCell(_ cellType: UITableViewCell.Type) {
        self.register(
            cellType.self,
            forCellReuseIdentifier: String(describing: cellType.self)
        )
    }

    func dequeueCell<T: UITableViewCell>(_ cellType: T.Type) -> T? {
        dequeueReusableCell(
            withIdentifier: String(describing: cellType.self)
        ) as? T
    }
}
