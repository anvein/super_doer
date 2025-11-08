import Foundation
import RxRelay
import RxCocoa
import RxSwift

class TextEditorViewModel: TextEditorViewModelType, TextEditorNavigationEmittable {

    private let disposeBag = DisposeBag()

    // MARK: - State / Rx

    let textRelay = BehaviorRelay<NSAttributedString?>(value: nil)

    private let titleRelay = BehaviorRelay<String?>(value: nil)
    var titleDriver: Driver<String?> { titleRelay.asDriver() }

    private let subtitleRelay = BehaviorRelay<String?>(value: nil)
    var subtitleDriver: Driver<String?> { subtitleRelay.asDriver() }

    let didTapReadyRelay = PublishRelay<Void>()
    let didDisappearRelay = PublishRelay<Void>()

    // MARK: - Navigation

    private let needSaveAndCloseRelay = PublishRelay<NSAttributedString?>()
    var needSaveAndClose: Signal<NSAttributedString?> { needSaveAndCloseRelay.asSignal() }

    // MARK: - Init

    init(data: TextEditorData) {
        textRelay.accept(data.text)
        titleRelay.accept(data.title)
        subtitleRelay.accept(data.subtitle)

        didTapReadyRelay
            .map { [weak self] in
                self?.textRelay.value
            }
            .bind(to: needSaveAndCloseRelay)
            .disposed(by: disposeBag)

        didDisappearRelay
            .map { [weak self] in
                self?.textRelay.value
            }
            .bind(to: needSaveAndCloseRelay)
            .disposed(by: disposeBag)
    }

}
