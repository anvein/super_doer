import Foundation
import RxRelay
import RxCocoa
import RxSwift

class TextEditorViewModel: TextEditorViewModelType, TextEditorNavigationEmittable {

    private let disposeBag = DisposeBag()

    // MARK: - State / Rx

    let textRelay = BehaviorRelay<NSAttributedString?>(value: nil)

    private let titleRelay = BehaviorRelay<String?>(value: nil)
    var titleDriver: Driver<String?> {
        titleRelay.asDriver()
    }

    private let subtitleRelay = BehaviorRelay<String?>(value: nil)
    var subtitleDriver: Driver<String?> {
        subtitleRelay.asDriver()
    }

    let didCloseRelay = PublishRelay<Void>()

    // MARK: - Navigation

    private let didCloseWithSaveRelay = PublishRelay<NSAttributedString?>()
    var didCloseWithSave: Signal<NSAttributedString?> { didCloseWithSaveRelay.asSignal() }

    // MARK: - Init

    init(data: TextEditorData) {
        textRelay.accept(data.text)
        titleRelay.accept(data.title)
        subtitleRelay.accept(data.subtitle)

        didCloseRelay
            .map { [weak self] in
                self?.textRelay.value
            }
            .bind(to: didCloseWithSaveRelay)
            .disposed(by: disposeBag)
    }

}
