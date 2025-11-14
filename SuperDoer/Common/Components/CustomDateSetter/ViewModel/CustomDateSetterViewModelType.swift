import Foundation
import RxCocoa

protocol CustomDateSetterViewModelType: AnyObject {

    var isShowReadyButton: Driver<Bool> { get }
    var isShowDeleteButton: Driver<Bool> { get }

    var date: Driver<Date> { get }

    var inputEvents: PublishRelay<CustomDateSetterViewModelInputEvent> { get }
}

