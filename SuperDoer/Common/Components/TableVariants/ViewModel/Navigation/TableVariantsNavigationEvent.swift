import Foundation

enum TableVariantsNavigationEvent<Value> {
    case didSelectValue(Value?)
    case didSelectCustomVariant(Value?)
}
