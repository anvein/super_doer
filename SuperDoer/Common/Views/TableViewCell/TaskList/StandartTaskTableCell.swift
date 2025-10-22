import UIKit
import SnapKit
import RxRelay
import RxSwift
import RxCocoa

class StandartTaskTableCell: UITableViewCell {

    enum Answer {
        case onTapIsDoneButton(IndexPath)
        case onTapIsPriorityButton(IndexPath)
    }

    // MARK: - Subviews

    private let contentContainerView = UIView()
    private let isDoneButton = CheckboxButton()
    private let rowsStackView = UIStackView()
    private let taskTitleLabel = UILabel()
    private let attributesLabel = UILabel()
    private let isPriorityButton = StarButton()

    // MARK: - Constraints / Rx

    private var bottomInsetConstraint: Constraint?

    var externalDisposeBag = DisposeBag()
    private let internalDisposeBag = DisposeBag()

    private let answerRelay: PublishRelay<Answer> = .init()
    var actionSignal: Signal<Answer> {
        answerRelay.asSignal()
    }

    // MARK: - State

    var isLast: Bool = false {
        didSet {
            bottomInsetConstraint?.update(inset: !isLast ? 2 : 0)
        }
    }
    
    // MARK: - Init

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)

        setupView()
        setupHierarchy()
        setupConstraints()
        setupBindings()
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
        externalDisposeBag = .init()
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

private extension StandartTaskTableCell {
    // MARK: - Setup

    func setupView() {
        backgroundColor = nil
        backgroundView = UIView()
        selectedBackgroundView = UIView()

        contentContainerView.backgroundColor = .Common.white
        contentContainerView.cornerRadius = 8

        rowsStackView.axis = .vertical
        rowsStackView.spacing = 3

        taskTitleLabel.textColor = .Text.black
        taskTitleLabel.font = .systemFont(ofSize: 16)
        taskTitleLabel.numberOfLines = 0

        attributesLabel.textColor = .Text.gray
        attributesLabel.font = .systemFont(ofSize: 14)
        attributesLabel.numberOfLines = 2

        isPriorityButton.isOnColor = .Common.blueGray
        isPriorityButton.isOffColor = .Common.blueGray
    }

    func setupHierarchy() {
        contentView.addSubview(contentContainerView)
        contentContainerView.addSubviews(isDoneButton, rowsStackView, isPriorityButton)
        rowsStackView.addArrangedSubview(taskTitleLabel)
        rowsStackView.addArrangedSubview(attributesLabel)
    }

    func setupConstraints() {
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

    func setupBindings() {
        isDoneButton.rx.tap
            .map { [weak self] in
                // TODO: переделать получение indexPath
                guard let self, let tableView = self.superview as? UITableView,
                      let indexPath = tableView.indexPath(for: self) else { return nil }

                return Answer.onTapIsDoneButton(indexPath)
            }
            .compactMap { $0 }
            .bind(to: answerRelay)
            .disposed(by: internalDisposeBag)

        isPriorityButton.rx.tap
            .map { [weak self] in
                // TODO: переделать получение indexPath
                guard let self, let tableView = self.superview as? UITableView,
                      let indexPath = tableView.indexPath(for: self) else { return nil }

                return Answer.onTapIsPriorityButton(indexPath)
            }
            .compactMap { $0 }
            .bind(to: answerRelay)
            .disposed(by: internalDisposeBag)
    }

    // MARK: - Update view

    func setCornerRadiusForSwipeButtons(state: UITableViewCell.StateMask) {
        // TODO: пофиксить:
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

}

// MARK: - HighlightableCell

extension StandartTaskTableCell: HighlightableCell {
    func setCellHighlighted(_ highlighted: Bool) {
        contentContainerView.backgroundColor = highlighted ? .TaskCell.selectedBackground : .Common.white
    }

}
