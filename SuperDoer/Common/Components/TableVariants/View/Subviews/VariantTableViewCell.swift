import UIKit

class VariantTableViewCell: UITableViewCell {

    var isSelectedValue = false {
        didSet {
            guard isSelectedValue != oldValue else { return }
            configureForState(isSelectedValue)
        }
    }

    // MARK: - Init

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(
            style: UITableViewCell.CellStyle.value1,
            reuseIdentifier: String(describing: Self.self)
        )
        
        setup()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - Update view

    func fill(from cellVM: VariantCellViewModelProtocol) {
        textLabel?.text = cellVM.title
        detailTextLabel?.text = cellVM.additionalText
        imageView?.image = createImage(
            with: cellVM.imageSettings.name,
            pointSize: Float(cellVM.imageSettings.size),
            weight: cellVM.imageSettings.weight
        )
        imageView?.tintColor = .Text.black
        accessoryType = cellVM is CustomVariantCellViewModelProtocol ? .disclosureIndicator : .none

        isSelectedValue = cellVM.isSelected
    }

    // MARK: - Setup

    private func setup() {
        backgroundColor = .Common.white
        selectedBackgroundView = UIView()
        selectedBackgroundView?.backgroundColor = .Common.lightBlueBg

        textLabel?.textColor = .Text.black
        textLabel?.font = UIFont.systemFont(ofSize: 16)
        
        detailTextLabel?.textColor = .Text.gray
        detailTextLabel?.font = UIFont.systemFont(ofSize: 13)

        configureForState(isSelectedValue)
    }

    private func configureForState(_ isSelected: Bool) {
        if isSelected {
            textLabel?.textColor = .Text.blue
            imageView?.tintColor = .Text.blue
            detailTextLabel?.textColor = .Text.blue
        } else {
            textLabel?.textColor = .Text.black
            imageView?.tintColor = .Text.black
            detailTextLabel?.textColor = .Text.gray
        }
    }
    
    // MARK: - Helpers

    private func createImage(with imageName: String, pointSize: Float, weight: UIImage.SymbolWeight) -> UIImage? {
        return UIImage(
            systemName: imageName,
            withConfiguration: UIImage.SymbolConfiguration(
                pointSize: pointSize.cgFloat,
                weight: weight
            )
        )?.withRenderingMode(.alwaysTemplate)
    }
}
