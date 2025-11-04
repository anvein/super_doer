import UIKit
import SnapKit
import RxRelay
import RxSwift
import RxCocoa

class StandartTaskTableCell: UITableViewCell {

    enum Answer {
        case onTapIsDoneButton(Bool, IndexPath)
        case onTapIsPriorityButton(Bool, IndexPath)
    }

    // MARK: - Subviews

    private let contentContainerView = UIView()
    private let isDoneToggle = CheckboxToggleView()
    private let rowsStackView = UIStackView()
    private let taskTitleLabel = UILabel()
    private let attributesLabel = UILabel()
    private let isPriorityToggle = StarToggleView()

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

    func fillFrom(viewModel: TaskTableCellViewModelType) {
        taskTitleLabel.text = viewModel.title
        taskTitleLabel.setStrikedStyle(viewModel.isCompleted)
        taskTitleLabel.textColor = viewModel.isCompleted ? .Text.gray : .Text.black

        isDoneToggle.value = viewModel.isCompleted
        isPriorityToggle.value = viewModel.isPriority

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

        isDoneToggle.visibleAreaInsets = 6

        taskTitleLabel.textColor = .Text.black
        taskTitleLabel.font = .systemFont(ofSize: 16)
        taskTitleLabel.numberOfLines = 0

        attributesLabel.textColor = .Text.gray
        attributesLabel.font = .systemFont(ofSize: 14)
        attributesLabel.numberOfLines = 2

        isPriorityToggle.imageInsets = 6
        isPriorityToggle.isOnColor = .Common.blueGray
        isPriorityToggle.isOffColor = .Common.blueGray
    }

    func setupHierarchy() {
        contentView.addSubview(contentContainerView)
        contentContainerView.addSubviews(isDoneToggle, rowsStackView, isPriorityToggle)
        rowsStackView.addArrangedSubview(taskTitleLabel)
        rowsStackView.addArrangedSubview(attributesLabel)
    }

    func setupConstraints() {
        contentContainerView.snp.makeConstraints {
            $0.top.horizontalEdges.equalToSuperview()
            $0.bottom.equalToSuperview().inset(2)
        }

        isDoneToggle.snp.makeConstraints {
            $0.size.equalTo(36)
            $0.leading.equalToSuperview().inset(10)
            $0.top.greaterThanOrEqualToSuperview().inset(14)
            $0.bottom.lessThanOrEqualToSuperview().inset(14)
            $0.centerY.equalToSuperview()
        }

        rowsStackView.snp.makeConstraints {
            $0.verticalEdges.equalToSuperview().inset(11).priority(.medium)
            $0.leading.equalTo(isDoneToggle.snp.trailing).offset(10)
        }

        isPriorityToggle.snp.makeConstraints {
            $0.size.equalTo(32)
            $0.leading.equalTo(rowsStackView.snp.trailing).offset(6)
            $0.trailing.equalToSuperview().inset(12)
            $0.top.greaterThanOrEqualToSuperview().inset(10)
            $0.bottom.lessThanOrEqualToSuperview().inset(10)
            $0.centerY.equalToSuperview()
        }
    }

    func setupBindings() {
        isDoneToggle.valueChangedSignal
            .map { [weak self] newValue in
                guard let indexPath = self?.getIndexPathBySuperview() else { return nil }
                return Answer.onTapIsDoneButton(newValue, indexPath)
            }
            .compactMap { $0 }
            .emit(to: answerRelay)
            .disposed(by: internalDisposeBag)

        isPriorityToggle.valueChangedSignal
            .map { [weak self] newValue in
                guard let indexPath = self?.getIndexPathBySuperview() else { return nil }
                return Answer.onTapIsPriorityButton(newValue, indexPath)
            }
            .compactMap { $0 }
            .emit(to: answerRelay)
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

    // MARK: - Helpers

    func getIndexPathBySuperview() -> IndexPath? {
        // TODO: переделать получение indexPath
        let tableView = self.superview as? UITableView
        return tableView?.indexPath(for: self)
    }

}

// MARK: - HighlightableCell

extension StandartTaskTableCell: HighlightableCell {
    func setCellHighlighted(_ highlighted: Bool) {
        contentContainerView.backgroundColor = highlighted ? .TaskCell.selectedBackground : .Common.white
    }

}
