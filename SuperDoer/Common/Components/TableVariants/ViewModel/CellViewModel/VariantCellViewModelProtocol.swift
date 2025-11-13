protocol VariantCellViewModelProtocol {
    var imageSettings: VariantCellVMImageSettings { get }
    var title: String { get }
    var additionalText: String? { get }
    var isSelected: Bool { get }
}
