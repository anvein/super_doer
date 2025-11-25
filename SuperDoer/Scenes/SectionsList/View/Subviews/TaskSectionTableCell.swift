import UIKit

final class TaskSectionTableCell: UITableViewCell {

    static let cellHeight = 48.4

    // MARK: - Init

    override init(style: UITableViewCell.CellStyle = .value1, reuseIdentifier: String?) {
        super.init(style: .value1, reuseIdentifier: reuseIdentifier)

        setupCell()
        setupConstraints()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - Update view

    func fillFrom(cellVM: TaskSectionCellViewModel) {
        textLabel?.text = cellVM.title
        detailTextLabel?.text = String(cellVM.tasksCount)

        configureCellImage(cellVM)
    }

    // MARK: - Setup

    private func setupCell() {
        imageView?.translatesAutoresizingMaskIntoConstraints = false

        textLabel?.translatesAutoresizingMaskIntoConstraints = false
        textLabel?.textColor = .Text.black
        textLabel?.font = UIFont.systemFont(ofSize: 17, weight: .medium)
        textLabel?.numberOfLines = 1

        detailTextLabel?.textColor = .Text.gray
        detailTextLabel?.font = UIFont.systemFont(ofSize: 15, weight: .regular)
        detailTextLabel?.numberOfLines = 1

        backgroundColor = .Common.white
    }

    private func setupConstraints() {
        imageView?.centerXAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 28).isActive = true
        imageView?.centerYAnchor.constraint(equalTo: contentView.centerYAnchor).isActive = true

        textLabel?.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 56).isActive = true
        textLabel?.rightAnchor.constraint(equalTo: contentView.rightAnchor, constant: -56).isActive = true
        textLabel?.centerYAnchor.constraint(equalTo: contentView.centerYAnchor).isActive = true
    }

    private func configureCellImage(_ cellViewModel: TaskSectionCellViewModel) {
        switch cellViewModel.icon {
        case .emoji(let emoji):
            // TODO: реализовать установку emoji
            break

        case .iconCofig(let sfSymbolName, let color, let size):
            let symbolConfig = UIImage.SymbolConfiguration(
                pointSize: size.cgFloat,
                weight: .bold
            )
            imageView?.image = UIImage(systemName: sfSymbolName, withConfiguration: symbolConfig)
            imageView?.tintColor = color
        }
    }

}
