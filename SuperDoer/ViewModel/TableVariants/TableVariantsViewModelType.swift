
import Foundation

protocol TableVariantsViewModelType {
    var isShowReadyButton: Box<Bool> { get }
    var isShowDeleteButton: Box<Bool> { get }
    
    var variantCellViewModels: Box<[BaseVariantCellViewModel]> { get }
    
    func getCountVariants() -> Int
    
    func getVariantCellViewModel(forIndexPath indexPath: IndexPath) -> BaseVariantCellViewModel
}
