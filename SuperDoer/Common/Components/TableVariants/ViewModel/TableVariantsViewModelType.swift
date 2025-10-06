
import Foundation

protocol TableVariantsViewModelType {
    var isShowReadyButtonObservable: UIBoxObservable<Bool> { get }
    var isShowDeleteButtonObservable: UIBoxObservable<Bool> { get }

    var variantCellViewModelsObservable: UIBoxObservable<[BaseVariantCellViewModel]> { get }

    func getCountVariants() -> Int
    
    func getVariantCellViewModel(forIndexPath indexPath: IndexPath) -> BaseVariantCellViewModel
}
