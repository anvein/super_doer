protocol TableVariantSelectedFinder {
    associatedtype Value
    func findSelectedIndex(of value: Value?, in items: [VariantCellViewModel<Value>]) -> Int?
}
