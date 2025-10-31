import UIKit
import SnapKit
import RxRelay
import RxSwift
import RxCocoa

final class CheckboxToggleView: UIView {

    private let button = UIButton()

    private let checkImageView = UIImageView()
    private let imageViewContainer = UIView()

    private var imageInsetsConstraint: Constraint?
    private var visibleAreaInsetsConstraint: Constraint?

    var visibleAreaInsets: CGFloat = 0 {
        didSet {
            visibleAreaInsetsConstraint?.update(inset: visibleAreaInsets)
        }
    }

    var imageInsets: CGFloat = 5.5 {
        didSet {
            imageInsetsConstraint?.update(inset: imageInsets)
        }
    }

    // MARK: - State / Rx

    private let disposeBag = DisposeBag()

    var value: Bool = false {
        didSet {
            guard oldValue != value else { return }
            setAppearanceForState(value)
        }
    }

    private var valueChangedRelay = PublishRelay<Bool>()
    var valueChangedSignal: Signal<Bool> {
        valueChangedRelay.distinctUntilChanged().asSignal(onErrorJustReturn: false)
    }

    // MARK: - Init

    init() {
        super.init(frame: .zero)
        setup()
        setupBindings()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - Lifecycle

    override func layoutSubviews() {
        super.layoutSubviews()
        imageViewContainer.cornerRadius = (button.bounds.width - visibleAreaInsets * 2) / 2
    }

}

private extension CheckboxToggleView {

    // MARK: - Setup

    func setup() {
        addSubview(button)
        button.addSubview(imageViewContainer)
        imageViewContainer.addSubview(checkImageView)

        button.snp.makeConstraints {
            $0.edges.equalToSuperview()
        }

        imageViewContainer.snp.makeConstraints {
            self.visibleAreaInsetsConstraint = $0.edges
                .equalToSuperview()
                .inset(visibleAreaInsets).constraint
        }

        checkImageView.snp.makeConstraints {
            self.imageInsetsConstraint = $0.edges.equalToSuperview().inset(imageInsets).constraint
        }

        imageViewContainer.borderWidth = 2
        imageViewContainer.isUserInteractionEnabled = false
        checkImageView.contentMode = .scaleAspectFill

        setAppearanceForState(value)
    }

    func setupBindings() {
        button.rx.tap
            .subscribe(onNext: { [weak self] _ in
                guard let self else { return }
                self.value.toggle()
                self.valueChangedRelay.accept(self.value)
            })
            .disposed(by: disposeBag)

        Observable
            .merge(
                button.rx.controlEvent([.touchDown, .touchDragEnter]).map { true },
                button.rx.controlEvent([.touchUpInside, .touchCancel, .touchDragExit]).map { false }
            )
            .distinctUntilChanged()
            .subscribe(onNext: { [weak self] isHighlighted in
                self?.animateImageViewContainer(for: isHighlighted)
            })
            .disposed(by: disposeBag)
    }

    // MARK: - Update view

    func setAppearanceForState(_ isOn: Bool) {
        if isOn {
            imageViewContainer.borderColor = .IsCompletedCheckbox.completedBg
            imageViewContainer.backgroundColor = UIColor.IsCompletedCheckbox.completedBg

            let image: UIImage = .Common.taskIsDoneCheckmark.withTintColor(.white, renderingMode: .alwaysOriginal)
            checkImageView.image = image
        } else {
            imageViewContainer.borderColor = .Common.darkGrayApp
            imageViewContainer.backgroundColor = UIColor.IsCompletedCheckbox.uncompletedBg

            checkImageView.image = nil
        }
    }

    func animateImageViewContainer(for isHighlighted: Bool) {
        UIView.animate(
            withDuration: 0.07,
            delay: 0,
            options: [.beginFromCurrentState, .allowUserInteraction]
        ) {
            self.imageViewContainer.transform = isHighlighted ? .init(scaleX: 0.9, y: 0.9) : .identity
        }
    }
}

// MARK: - Preview

@available(iOS 17, *)
#Preview {
     {
        let btn = CheckboxToggleView()
        btn.frame = .init(origin: .zero, size: .init(width: 40, height: 40))
        return btn
    }()
}
