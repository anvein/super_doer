
import UIKit

class AddSubtaskButtonCell: TaskViewBaseButtonCell {
    
    typealias State = Bool
    
    override class var identifier: String {
        return "AddSubtaskButtonCell"
    }
    
    override var showBottomSeparator: Bool {
        return true
    }
    
    // MARK: properties for cell button
    override var rowHeight: Int {
        return 68
    }
    
    var isEdit: State = false {
        didSet {
            guard isEdit != oldValue else {
                return
            }
            
            configureCellForState(isEdit)
        }
    }
    
    let leftImageView = UIImageView()
    let subtaskTextField = UITextField()
    
    lazy var plusImage: UIImage? = AddSubtaskButtonCell.createPlusImage()
    lazy var circleImage: UIImage? = AddSubtaskButtonCell.createCircleImage()
    
    
    // MARK: init
    override init(style: UITableViewCell.CellStyle = .default, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        addSubviews()
        setupViews()
        setupConstraints()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: setup methods
    override func setupViews()
    {
        super.setupViews()
        
        backgroundColor = nil
        backgroundView = UIView()
        selectedBackgroundView = UIView()
        
        leftImageView.translatesAutoresizingMaskIntoConstraints = false
        
        subtaskTextField.translatesAutoresizingMaskIntoConstraints = false
        subtaskTextField.placeholder = "Новая подзадача"
        subtaskTextField.textColor = InterfaceColors.blackText
        subtaskTextField.returnKeyType = .done
        
        actionButton.isHidden = true
        
        subtaskTextField.addTarget(self, action: #selector(subtaskTextFieldEditingDidBegin(textField:)), for: .editingDidBegin)
        subtaskTextField.addTarget(self, action: #selector(subtaskTextFieldEditingDidEnd(textField:)), for: .editingDidEnd)
        
        configureCellForState(isEdit)
    }

    override func addSubviews() {
        super.addSubviews()
        
        contentView.addSubview(leftImageView)
        contentView.addSubview(subtaskTextField)
    }
    
    override func setupConstraints() {
        super.setupConstraints()
        
        // leftImageView
        NSLayoutConstraint.activate([
            leftImageView.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
            leftImageView.centerXAnchor.constraint(equalTo: contentView.leftAnchor, constant: 32)
        ])
        
        // subtaskTextField
        NSLayoutConstraint.activate([
            subtaskTextField.topAnchor.constraint(equalTo: contentView.topAnchor),
            subtaskTextField.bottomAnchor.constraint(equalTo: contentView.bottomAnchor),
            subtaskTextField.leftAnchor.constraint(equalTo: leftImageView.centerXAnchor, constant: 32),
            subtaskTextField.rightAnchor.constraint(equalTo: contentView.rightAnchor, constant: -64),
        ])
    }
    
    func configureCellForState(_ isEdited: State) {
        if isEdited {
            setSubtaskFieldPlaceholderStyle(color: InterfaceColors.textGray)
            leftImageView.tintColor = InterfaceColors.textGray
            
            leftImageView.image = circleImage
        } else {
            setSubtaskFieldPlaceholderStyle(color: InterfaceColors.textBlue)
            leftImageView.tintColor = InterfaceColors.textBlue
            
            leftImageView.image = plusImage
        }
    }
    
    private func setSubtaskFieldPlaceholderStyle(color: UIColor) {
        if let attributedPlaceholder = subtaskTextField.attributedPlaceholder?.mutableCopy() as? NSMutableAttributedString {
            attributedPlaceholder.setAttributes(
                [.foregroundColor: color],
                range: NSRange(location: 0, length: attributedPlaceholder.length)
            )
            
            subtaskTextField.attributedPlaceholder = attributedPlaceholder
        }
    }
    
    
    // MARK: handlers
    @objc func subtaskTextFieldEditingDidBegin(textField: UITextField) {
        isEdit = true
        configureCellForState(isEdit)
    }
    
    @objc func subtaskTextFieldEditingDidEnd(textField: UITextField) {
        isEdit = false
        configureCellForState(isEdit)
    }
    
    
    // MARK: methods helpers
    private static func createPlusImage() -> UIImage? {
        let symbolConfig = UIImage.SymbolConfiguration(pointSize: 22, weight: .regular)
    
        return UIImage(systemName: "plus")?
            .withConfiguration(symbolConfig)
            .withTintColor(InterfaceColors.textBlue, renderingMode: .alwaysOriginal)
    }
    
    private static func createCircleImage() -> UIImage? {
        let symbolConfig = UIImage.SymbolConfiguration(pointSize: 22, weight: .regular)
    
        return UIImage(systemName: "circle")?
            .withConfiguration(symbolConfig)
            .withRenderingMode(.alwaysTemplate)
    }
    
}


