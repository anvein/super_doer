
import Foundation

protocol TableDateVariantsViewModelType {
    var isShowReadyButton: Box<Bool> { get }
    var isShowDeleteButton: Box<Bool> { get }
    
    var variantsCellValuesArray: Box<[BaseVariantCellValue]> { get }
    
    func getCountVariants() -> Int
    
    func getVariantCellValue(forIndexPath indexPath: IndexPath) -> BaseVariantCellValue
}
