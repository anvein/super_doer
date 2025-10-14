
import UIKit
import SnapKit

final class TaskDetailAddSubtaskCell: TaskDetailBaseCell {

    typealias State = Bool

    // MARK: - Settings

    private static let plusHeight: CGFloat = 26
    private static let plusWidth: CGFloat = 23

    private static let circleSize: CGFloat = 24

    override var showBottomSeparator: Bool { true }
    override class var rowHeight: Int { 68 }

    // MARK: - State

    var isEdit: State = false {
        didSet {
            guard isEdit != oldValue else { return }
            configureCellForState(isEdit)
        }
    }

    // MARK: - Subviews

    private let leftImageView = UIImageView()
    let titleTextField = UITextField()

    private lazy var plusImage: UIImage? = TaskDetailAddSubtaskCell.createPlusImage()
    private lazy var circleImage: UIImage? = TaskDetailAddSubtaskCell.createCircleImage()

    // MARK: - Constraints

    private var leftImageHeightConstraint: Constraint?
    private var leftImageWidthConstraint: Constraint?

    // MARK: - Init

    override init(style: UITableViewCell.CellStyle = .default, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        addSubviews()
        setupSubviews()
        setupConstraints()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - State

    override func setupSubviews() {
        super.setupSubviews()

        backgroundColor = nil
        backgroundView = UIView()
        selectedBackgroundView = UIView()

        actionButton.isHidden = true

        titleTextField.placeholder = "Новая подзадача"
        titleTextField.textColor = .Text.black
        titleTextField.returnKeyType = .done

        titleTextField.addTarget(self, action: #selector(subtaskTextFieldEditingDidBegin(textField:)), for: .editingDidBegin)
        titleTextField.addTarget(self, action: #selector(subtaskTextFieldEditingDidEnd(textField:)), for: .editingDidEnd)

        configureCellForState(isEdit)
    }

    override func addSubviews() {
        super.addSubviews()
        contentView.addSubviews(leftImageView, titleTextField)
    }
    
    override func setupConstraints() {
        super.setupConstraints()

        leftImageView.snp.makeConstraints { [weak self] in
            // почему-то без изменения приоритета при обновлении размера был конфликт констрэинтов
            self?.leftImageWidthConstraint = $0.width.equalTo(Self.plusWidth).priority(.high).constraint
            self?.leftImageHeightConstraint = $0.height.equalTo(Self.plusHeight).priority(.high).constraint
            $0.leading.equalToSuperview().offset(20)
            $0.centerY.equalToSuperview()
        }

        titleTextField.snp.makeConstraints {
            $0.verticalEdges.equalToSuperview()
            $0.leading.equalTo(leftImageView.snp.centerX).offset(32)
            $0.trailing.equalToSuperview().inset(64)
        }
    }
    
    func configureCellForState(_ isEditing: State) {
        if isEditing {
            setSubtaskFieldPlaceholderStyle(color: .Text.gray)
            leftImageView.tintColor = .Text.gray
            leftImageView.image = circleImage
            updateLeftImageSize(width: Self.circleSize, height: Self.circleSize)
        } else {
            setSubtaskFieldPlaceholderStyle(color: .Text.blue)
            leftImageView.tintColor = .Text.blue
            leftImageView.image = plusImage
            updateLeftImageSize(width: Self.plusWidth, height: Self.plusHeight)
        }
    }
}

private extension TaskDetailAddSubtaskCell {

    // MARK: - Actions handlers

    @objc func subtaskTextFieldEditingDidBegin(textField: UITextField) {
        isEdit = true
        configureCellForState(isEdit)
    }

    @objc func subtaskTextFieldEditingDidEnd(textField: UITextField) {
        isEdit = false
        configureCellForState(isEdit)
    }

    // MARK: - Update view

    func updateLeftImageSize(width: CGFloat, height: CGFloat) {
        leftImageWidthConstraint?.update(offset: width)
        leftImageHeightConstraint?.update(offset: height)
    }

    func setSubtaskFieldPlaceholderStyle(color: UIColor) {
        if let attributedPlaceholder = titleTextField.attributedPlaceholder?.mutableCopy() as? NSMutableAttributedString {
            attributedPlaceholder.setAttributes(
                [.foregroundColor: color],
                range: NSRange(location: 0, length: attributedPlaceholder.length)
            )

            titleTextField.attributedPlaceholder = attributedPlaceholder
        }
    }

    // MARK: - Helpers

    static func createPlusImage() -> UIImage? {
        let symbolConfig = UIImage.SymbolConfiguration(weight: .regular)

        return UIImage(systemName: "plus")?
            .withConfiguration(symbolConfig)
            .withTintColor(.Text.blue, renderingMode: .alwaysOriginal)
    }

    static func createCircleImage() -> UIImage? {
        let symbolConfig = UIImage.SymbolConfiguration(weight: .regular)

        return UIImage(systemName: "circle")?
            .withConfiguration(symbolConfig)
            .withRenderingMode(.alwaysTemplate)
    }
}
