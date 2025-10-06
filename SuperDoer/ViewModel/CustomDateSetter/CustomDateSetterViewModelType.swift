
import Foundation

protocol CustomDateSetterViewModelType: AnyObject {
    var isShowReadyButtonObservable: UIBoxObservable<Bool> { get }
    var isShowDeleteButtonObservable: UIBoxObservable<Bool> { get }

    var deadlineDateObservable: UIBoxObservable<Date?> { get }
    
    var defaultDate: Date { get }
}
