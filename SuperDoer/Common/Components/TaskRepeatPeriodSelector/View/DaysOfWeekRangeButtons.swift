import RxCocoa
import RxRelay
import UIKit

final class DaysOfWeekRangeButtons: UIView {

    private let onTapButtonRelay = PublishRelay<RepeatPeriodDayOfWeakViewModel>()
    var onTapButtonEvent: Signal<RepeatPeriodDayOfWeakViewModel> { onTapButtonRelay.asSignal() }

    // MARK: - State

    var selectedColor: UIColor = .Common.blue
    var buttonsSize: CGFloat = 44
    private(set) var values: [RepeatPeriodDayOfWeakViewModel] = []

    var itemsCount: Int { values.count }

    // MARK: - Subviews

    private let stackView: UIStackView = .init()
    private var buttons: [UIButton] = []

    // MARK: - Init

    init() {
        super.init(frame: .zero)
        setupHierarchy()
        setupView()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - Setup

    private func setupHierarchy() {
        addSubview(stackView)
        stackView.snp.makeConstraints {
            $0.edges.equalToSuperview()
        }
    }

    private func setupView() {
        stackView.axis = .horizontal
        stackView.alignment = .center
        stackView.distribution = .equalSpacing
    }

    private func buildButtons() {
        stackView.removeAllArrangedSubviews()
        buttons.forEach {
            $0.removeFromSuperview()
        }
        buttons = []

        for index in values.indices {
            let button = UIButton()
            button.backgroundColor = .clear
            button.borderWidth = 1
            button.borderColor = .Common.darkGrayApp

            let title = values[safe: index]?.title ?? "-"
            button.setTitle(title, for: .normal)
            button.setTitleColor(.black, for: .normal)
            button.titleLabel?.font = UIFont.systemFont(ofSize: 15)

            button.rx.tap
                .subscribe(onNext: { [weak self] _ in
                    if let self, var buttonValue = self.values[safe: index] {
                        buttonValue.isSelected.toggle()
                        self.values[index] = buttonValue
                        self.onTapButtonRelay.accept(buttonValue)
                        self.updateButtonsState()
                    }
                })
                .disposed(by: button.disposeBag)

            button.snp.makeConstraints {
                $0.size.equalTo(buttonsSize)
            }
            button.cornerRadius = buttonsSize / 2

            stackView.addArrangedSubview(button)
            buttons.append(button)
        }
    }

    // MARK: - Update view

    func updateContent(values: [RepeatPeriodDayOfWeakViewModel], fullRebuild: Bool = false) {
        let beforeOnlyIndexes = self.values.map { $0.index }
        let newOnlyIndexes = values.map { $0.index }
        self.values = values

        if beforeOnlyIndexes.isEmpty || beforeOnlyIndexes != newOnlyIndexes || fullRebuild {
            buildButtons()
        }

        updateButtonsState()
    }

    func updateSelectedValues(by selectedIndexes: Set<Int>) {
        for (arrayIndex, dayVM) in values.enumerated() {
            var updatedDayVM = dayVM
            updatedDayVM.isSelected = selectedIndexes.contains(dayVM.index)
            values[arrayIndex] = updatedDayVM
        }
        updateButtonsState()
    }

    private func updateButtonsState() {
        values.enumerated().forEach { index, valueItem in
            guard let button = buttons[safe: index] else { return }

            if valueItem.isSelected {
                button.backgroundColor = selectedColor
                button.borderColor = selectedColor
                button.setTitleColor(.white, for: .normal)
            } else {
                button.backgroundColor = .clear
                button.borderColor = .Common.darkGrayApp
                button.setTitleColor(.black, for: .normal)
            }
        }
    }

}
