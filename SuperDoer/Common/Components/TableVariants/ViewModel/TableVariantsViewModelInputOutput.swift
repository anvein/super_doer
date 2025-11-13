import Foundation
import RxCocoa

protocol TableVariantsViewModelInputOutput {
    var tableNeedReload: Signal<Void> { get }

    var isShowReadyButton: Driver<Bool> { get }
    var isShowDeleteButton: Driver<Bool> { get }

    func getCountVariants() -> Int
    func getVariantCellViewModel(for indexPath: IndexPath) -> VariantCellViewModelProtocol?

    func didTapSelectVariant(with indexPath: IndexPath)
    func didTapDelete()
    func didTapReady()
}
