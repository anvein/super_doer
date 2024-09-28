
import UIKit
import SnapKit

class StandartTaskTableViewCell: UITableViewCell {

    weak var delegate: StandartTaskTableViewCellDelegate?

    // MARK: - Subviews

    private var contentContainerView: UIView = {
        $0.backgroundColor = .Common.white
        $0.cornerRadius = 8
        return $0
    }(UIView())

    private lazy var isDoneButton: CheckboxButton = {
        $0.addTarget(self, action: #selector(didTapIsDoneButton), for: .touchUpInside)
        return $0
    }(CheckboxButton())

    private let rowsStackView: UIStackView = {
        $0.axis = .vertical
        $0.spacing = 2
        return $0
    }(UIStackView())

    private let taskTitleLabel: UILabel = {
        $0.textColor = .Text.black
        $0.font = .systemFont(ofSize: 16)
        $0.numberOfLines = 0
        return $0
    }(UILabel())

    private let attributesLabel: UILabel = {
        $0.textColor = .Text.gray
        $0.font = .systemFont(ofSize: 14)
        $0.numberOfLines = 2
        return $0
    }(UILabel())

    // MARK: - Constraints

    private var bottomInsetConstraint: Constraint?

    // MARK: - State

    var showSectionTitle: Bool = false

    var isLast: Bool = false {
        didSet {
            bottomInsetConstraint?.update(inset: !isLast ? 2 : 0)
        }
    }
    
    // MARK: - Init

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)

        setup()
        setupConstraints()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - Lifecycle

    internal override func willTransition(to state: UITableViewCell.StateMask) {
        // MARK: - Допилить
        super.willTransition(to: state)
        if state.contains(.showingDeleteConfirmation) {
            if let deleteButton = superview?.subviews.first(where: { String(describing: type(of: $0)) == "UISwipeActionPullView" }) {
                deleteButton.cornerRadius = 8
            }
        }
    }

    // MARK: - Update view

    func fillFrom(viewModel: TaskTableViewCellViewModelType) {
        taskTitleLabel.text = viewModel.title
        isDoneButton.isOn = viewModel.isCompleted

        attributesLabel.attributedText = viewModel.attributes
        attributesLabel.isHidden = viewModel.attributes == nil
    }

}

private extension StandartTaskTableViewCell {
    // MARK: - Setup

    private func setup() {
        contentView.addSubview(contentContainerView)
        contentContainerView.addSubviews(isDoneButton, rowsStackView)
        rowsStackView.addArrangedSubview(taskTitleLabel)
        rowsStackView.addArrangedSubview(attributesLabel)

        backgroundColor = nil
        backgroundView = UIView()
        selectedBackgroundView = UIView()

//        contentContainerView.layer.shadowColor = UIColor.lightGray.cgColor
//        contentContainerView.layer.shadowOffset = CGSize(width: 5, height: 5)
//        contentContainerView.layer.shadowOpacity = 1
//        contentContainerView.layer.shadowRadius = 10
//        contentContainerView.clipsToBounds = false
    }

    private func setupConstraints() {
        contentContainerView.snp.makeConstraints {
            $0.top.horizontalEdges.equalToSuperview()
            $0.bottom.equalToSuperview().inset(2)
        }

        isDoneButton.snp.makeConstraints {
            $0.size.equalTo(24)
            $0.top.greaterThanOrEqualToSuperview().inset(14)
            $0.bottom.lessThanOrEqualToSuperview().inset(14)
            $0.leading.equalToSuperview().inset(16)
            $0.centerY.equalToSuperview()
        }

        rowsStackView.snp.makeConstraints {
            $0.verticalEdges.equalToSuperview().inset(12).priority(.medium)
            $0.leading.equalTo(isDoneButton.snp.trailing).offset(16)
            $0.trailing.equalToSuperview().inset(16)
        }
    }

    // MARK: - Actions handlers

    @objc func didTapIsDoneButton() {
        guard let tableView = self.superview as? UITableView,
              let indexPath = tableView.indexPath(for: self) else { return }

        delegate?.standartTaskCellDidTapIsDoneButton(indexPath: indexPath)
    }

}

// MARK: - Helpers

extension StandartTaskTableViewCell: HighlightableCell {
    func setCellHighlighted(_ highlighted: Bool) {
        contentContainerView.backgroundColor = highlighted ? .TaskCell.selectedBackground : .Common.white
    }

}
