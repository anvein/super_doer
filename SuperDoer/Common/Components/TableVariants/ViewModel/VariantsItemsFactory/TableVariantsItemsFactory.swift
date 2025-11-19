protocol TableVariantsItemsFactory {
    associatedtype CellValueType
    func buildCellViewModels() -> [VariantCellViewModel<CellValueType>]
}
