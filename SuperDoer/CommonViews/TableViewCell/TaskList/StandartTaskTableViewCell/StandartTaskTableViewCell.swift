
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
        $0.spacing = 3
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

    private lazy var isPriorityButton: StarButton = {
        $0.isOnColor = .Common.blueGray
        $0.isOffColor = .Common.blueGray
        $0.addTarget(self, action: #selector(didTapIsPriorityButton), for: .touchUpInside)
        return $0
    }(StarButton())

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

    override func willTransition(to state: UITableViewCell.StateMask) {
        super.willTransition(to: state)
        setCornerRadiusForSwipeButtons(state: state)
    }

    override func prepareForReuse() {
        super.prepareForReuse()

    }

    // MARK: - Update view

    func fillFrom(viewModel: TaskTableViewCellViewModelType) {
        taskTitleLabel.text = viewModel.title
        taskTitleLabel.setStrikedStyle(viewModel.isCompleted)
        taskTitleLabel.textColor = viewModel.isCompleted ? .Text.gray : .Text.black

        isDoneButton.isOn = viewModel.isCompleted
        isPriorityButton.isOn = viewModel.isPriority

        attributesLabel.attributedText = viewModel.attributes
        attributesLabel.isHidden = viewModel.attributes == nil

        reloadInputViews()
    }

}

private extension StandartTaskTableViewCell {
    // MARK: - Setup

    private func setup() {
        contentView.addSubview(contentContainerView)
        contentContainerView.addSubviews(isDoneButton, rowsStackView, isPriorityButton)
        rowsStackView.addArrangedSubview(taskTitleLabel)
        rowsStackView.addArrangedSubview(attributesLabel)

        backgroundColor = nil
        backgroundView = UIView()
        selectedBackgroundView = UIView()
    }

    private func setupConstraints() {
        contentContainerView.snp.makeConstraints {
            $0.top.horizontalEdges.equalToSuperview()
            $0.bottom.equalToSuperview().inset(2)
        }

        isDoneButton.snp.makeConstraints {
            $0.size.equalTo(24)
            $0.leading.equalToSuperview().inset(16)
            $0.top.greaterThanOrEqualToSuperview().inset(14)
            $0.bottom.lessThanOrEqualToSuperview().inset(14)
            $0.centerY.equalToSuperview()
        }

        rowsStackView.snp.makeConstraints {
            $0.verticalEdges.equalToSuperview().inset(11).priority(.medium)
            $0.leading.equalTo(isDoneButton.snp.trailing).offset(16)
        }

        isPriorityButton.snp.makeConstraints {
            $0.size.equalTo(24)
            $0.leading.equalTo(rowsStackView.snp.trailing).offset(10)
            $0.trailing.equalToSuperview().inset(16)
            $0.top.greaterThanOrEqualToSuperview().inset(14)
            $0.bottom.lessThanOrEqualToSuperview().inset(14)
            $0.centerY.equalToSuperview()
        }
    }

    // MARK: - Update view

    func setCornerRadiusForSwipeButtons(state: UITableViewCell.StateMask) {
        // допилить, баги:
        // - если у одной ячейки открыты swipe actions, то при открытии другой кнопки не скругляются
        // - если при закрытии действий willTransition() не отработала, то кнопки не скругляются
        // особенность: willTransition() срабатывает с задержкой после того, как действия закрыты

        guard state.contains(.showingDeleteConfirmation) else { return }

        let swipeActionPullView = superview?.subviews.first(where: {
            return String(describing: type(of: $0)) == "UISwipeActionPullView"
        })

        if let swipeActionPullView {
            swipeActionPullView.cornerRadius = 8
            swipeActionPullView.subviews.forEach({
                if String(describing: type(of: $0)) == "UISwipeActionStandardButton" {
                    $0.cornerRadius = 8
                }
            })
        }
    }

    // MARK: - Actions handlers

    @objc func didTapIsDoneButton() {
        guard let tableView = self.superview as? UITableView,
              let indexPath = tableView.indexPath(for: self) else { return }

        delegate?.standartTaskCellDidTapIsDoneButton(indexPath: indexPath)
    }

    @objc func didTapIsPriorityButton() {
        guard let tableView = self.superview as? UITableView,
              let indexPath = tableView.indexPath(for: self) else { return }

        delegate?.standartTaskCellDidTapIsPriorityButton(indexPath: indexPath)
    }

}

// MARK: - Helpers

extension StandartTaskTableViewCell: HighlightableCell {
    func setCellHighlighted(_ highlighted: Bool) {
        contentContainerView.backgroundColor = highlighted ? .TaskCell.selectedBackground : .Common.white
    }

}
