import RxCocoa

protocol DismissableController {
    var didDismiss: Signal<Void> { get }
}
