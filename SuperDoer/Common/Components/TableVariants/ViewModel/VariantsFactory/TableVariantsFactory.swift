protocol TableVariantsFactory {
    associatedtype CellValueType
    func buildCellViewModels() -> [VariantCellViewModel<CellValueType>]
}
