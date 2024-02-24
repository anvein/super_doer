
import Foundation

protocol VariantsViewModelType {
//    var isShowReadyButton: Bool { get }
//    var isShowDeleteButton: Bool { get }
    
    var variantsCellValuesArray: Box<[BaseVariantCellValue]> { get }
    
    func getCountVariants() -> Int
    
    func getVariantCellValue(forIndexPath indexPath: IndexPath) -> BaseVariantCellValue
}
