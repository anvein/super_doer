import UIKit
import SnapKit
import RxRelay
import RxSwift
import RxCocoa

final class StarToggleView: UIView {

    // MARK: - Settings

    var isOnColor: UIColor = .Common.blue
    var isOffColor: UIColor = .Common.darkGrayApp

    // MARK: - Subviews

    private let button = UIButton()
    private let starImageView = UIImageView()

    private var imageInsetsConstraint: Constraint?

    var imageInsets: CGFloat = 0 {
        didSet {
            imageInsetsConstraint?.update(inset: imageInsets)
        }
    }

    // MARK: - State / Rx

    private let disposeBag = DisposeBag()

    var value: Bool = false {
        didSet {
            guard oldValue != value else { return }
            setAppearanceForValue(value)
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

}

private extension StarToggleView {

    // MARK: - Setup

    func setup() {
        addSubview(button)
        button.addSubview(starImageView)

        button.snp.makeConstraints {
            $0.edges.equalToSuperview()
        }

        starImageView.snp.makeConstraints {
            self.imageInsetsConstraint = $0.edges
                .equalToSuperview()
                .inset(imageInsets).constraint
        }

        starImageView.contentMode = .scaleAspectFill

        setAppearanceForValue(value)
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
                self?.animateImageView(for: isHighlighted)
            })
            .disposed(by: disposeBag)
    }

    // MARK: - Update view

    func setAppearanceForValue(_ isOn: Bool) {
        let starImage: UIImage
        if isOn {
            starImage = .SfSymbol.starFill.withTintColor(isOnColor, renderingMode: .alwaysOriginal)
        } else {
            starImage = .SfSymbol.star.withTintColor(isOffColor, renderingMode: .alwaysOriginal)
        }

        starImageView.image = starImage
    }

    func animateImageView(for isHighlighted: Bool) {
        UIView.animate(
            withDuration: 0.1,
            delay: 0,
            options: [.beginFromCurrentState, .allowUserInteraction]
        ) {
            self.starImageView.transform = isHighlighted ? .init(scaleX: 0.9, y: 0.9) : .identity
        }
    }
}
