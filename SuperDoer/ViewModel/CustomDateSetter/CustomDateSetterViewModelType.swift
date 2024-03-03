
import Foundation

protocol CustomDateSetterViewModelType: AnyObject {
    var isShowReadyButton: Box<Bool> { get }
    var isShowDeleteButton: Box<Bool> { get }
    
    var date: Box<Date?> { get }
    
    var defaultDate: Date { get }
}
