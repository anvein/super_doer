import RxCocoa

final class AnyTableVariantsNavigationEmittable<Value>: TableVariantsNavigationEmittable {
    private let _navigationEvent: Signal<TableVariantsNavigationEvent<Value>>

    var navigationEvent: Signal<TableVariantsNavigationEvent<Value>> { _navigationEvent }

    init<VM: TableVariantsNavigationEmittable>(_ vm: VM) where VM.NavigationValue == Value {
        self._navigationEvent = vm.navigationEvent
    }
}
