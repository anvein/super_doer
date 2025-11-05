import Foundation
import RxCocoa

protocol TableVariantsViewModelType {

    var tableNeedReload: Signal<Void> { get }

    var isShowReadyButton: Driver<Bool> { get }
    var isShowDeleteButton: Driver<Bool> { get }

    func getCountVariants() -> Int
    func getVariantCellViewModel(for indexPath: IndexPath) -> BaseVariantCellViewModel?

    func didTapSelectVariant(with indexPath: IndexPath)
    func didTapDelete()
    func didTapReady()

}
