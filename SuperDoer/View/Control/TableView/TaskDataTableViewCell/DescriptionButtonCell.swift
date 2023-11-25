
import UIKit

/// Кнопка-ячейка для "Описания задачи"
class DescriptionButtonCell: UITableViewCell {
    
    enum State {
        case empty
        case textFilled
    }
    
    static let identifier = "DescriptionButtonCell"
    
    let emptyHeight = 135
    let maxHeight = 172
    
    var state: State = .empty
    
    var mainTextHeightConstraint: NSLayoutConstraint?
    
    weak var delegate: DescriptionButtonCellDelegateProtocol?
    
    
    // MARK: content view controls
    private let mainTextLabel = UILabel()
    private let infoLabel = UILabel()
    
    private let openButton = UIButton()
    
    private lazy var bottomSeparator = UIView()
    
    
    // MARK: init
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        setupCell()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
    // MARK: setup methods
    private func setupCell() {
        addSubviews()
        setupConstraints()
        setupViews()
    }
    
    private func addSubviews() {
        contentView.addSubview(mainTextLabel)
        contentView.addSubview(infoLabel)
        contentView.addSubview(openButton)
        
        contentView.addSubview(bottomSeparator)
    }
    
    private func setupViews() {
        // setup cell
        backgroundColor = nil
        backgroundView = UIView()
        
        selectedBackgroundView = UIView()
        selectedBackgroundView?.backgroundColor = InterfaceColors.controlsLightBlueBg
        
        // setup content views
        mainTextLabel.translatesAutoresizingMaskIntoConstraints = false
        mainTextLabel.font = mainTextLabel.font.withSize(16)
        mainTextLabel.numberOfLines = 6
        mainTextLabel.lineBreakMode = .byTruncatingTail
        
        infoLabel.translatesAutoresizingMaskIntoConstraints = false
        infoLabel.numberOfLines = 1
        infoLabel.font = infoLabel.font.withSize(14)
        infoLabel.textColor = InterfaceColors.textGray
        
        openButton.translatesAutoresizingMaskIntoConstraints = false
        openButton.titleLabel?.font = openButton.titleLabel?.font.withSize(14)
        openButton.setTitleColor(InterfaceColors.textBlue, for: .normal)
        openButton.setTitleColor(InterfaceColors.blackText, for: .selected)
        openButton.setTitle("Открыть", for: .normal)
        openButton.addTarget(self, action: #selector(pressOpenButton), for: .touchUpInside)
        
        bottomSeparator.translatesAutoresizingMaskIntoConstraints = false
        bottomSeparator.backgroundColor = InterfaceColors.TaskViewButtonCell.separator
        
        configureCellForState(state)
    }
    
    private func configureCellForState(_ state: State) {
        switch state {
        case .empty:
            mainTextLabel.text = "Добавить заметку"
            mainTextLabel.textColor = InterfaceColors.textGray
            mainTextLabel.font = UIFont.systemFont(ofSize: 16)
            
            infoLabel.text = nil
            infoLabel.isHidden = true
            openButton.isHidden = true
            
//            contentViewHeightConstraint?.isActive = true
            
        case .textFilled:
            infoLabel.isHidden = false
            infoLabel.text = "Обновлено: несколько секунд назад"
            
            mainTextLabel.textColor = InterfaceColors.blackText
            mainTextLabel.font = UIFont.systemFont(ofSize: 16)
            
            openButton.isHidden = false
        }
    }
    
    
    private func setupConstraints() {
        // contentView
        contentView.heightAnchor.constraint(equalToConstant: emptyHeight.cgFloat)
            .isActive = true
        
        // mainTextLabel
        NSLayoutConstraint.activate([
            mainTextLabel.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 15),
            mainTextLabel.leftAnchor.constraint(equalTo: contentView.leftAnchor, constant: 16),
            mainTextLabel.rightAnchor.constraint(equalTo: contentView.rightAnchor, constant: -16),
//            mainTextLabel.heightAnchor.constraint(greaterThanOrEqualToConstant: 120),
        ])
        
        // infoLabel
        NSLayoutConstraint.activate([
            infoLabel.topAnchor.constraint(equalTo: mainTextLabel.bottomAnchor, constant: 16),
            infoLabel.leftAnchor.constraint(equalTo: contentView.leftAnchor, constant: 16),
            infoLabel.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -19),
            infoLabel.rightAnchor.constraint(lessThanOrEqualTo: openButton.leftAnchor, constant: 19),
        ])
        
        // openButton
        NSLayoutConstraint.activate([
            openButton.topAnchor.constraint(greaterThanOrEqualTo: mainTextLabel.bottomAnchor, constant: 16),
            openButton.rightAnchor.constraint(equalTo: contentView.rightAnchor, constant: -16),
            openButton.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -19),
        ])
            
        // bottomSeparator
        NSLayoutConstraint.activate([
            bottomSeparator.bottomAnchor.constraint(equalTo: bottomAnchor),
            bottomSeparator.leftAnchor.constraint(equalTo: leftAnchor, constant: 16),
            bottomSeparator.rightAnchor.constraint(equalTo: contentView.rightAnchor, constant: -16),
            bottomSeparator.heightAnchor.constraint(equalToConstant: 0.5),
        ])
    }
    
    
    // MARK: action-handlers
    @objc func pressOpenButton() {
        delegate?.pressTaskDescriptionOpenButton()
    }
    
    
    // MARK: methods helpers
    // TODO: пока костыль + текст надо изменять только при помощи этого метода
    // TODO: надо придумать, как отслеживать изменение mainTextLabel.text и изменять state при изменении mainTextLabel.text
    func fillCellData(content: NSAttributedString?, updatedAt: Date?) {
        fillContent(attributedText: content)
        fillInfoLabel(dateUpdated: updatedAt)
    }
    
    func fillContent(attributedText: NSAttributedString?) {
        if attributedText == nil || attributedText?.length == 0 {
            mainTextLabel.attributedText = nil
            
            state = .empty
        } else {
            mainTextLabel.attributedText = attributedText
            
            state = .textFilled
        }
        
        configureCellForState(state)
    }
    
    func fillInfoLabel(dateUpdated: Date?) {
        if let fillDateUpdated = dateUpdated {
            let calendar = Calendar.current
            let dateComponents = calendar.dateComponents([.day, .month, .year, .hour, .minute, .second], from: fillDateUpdated)
            
            infoLabel.text = "Обновлено \(dateComponents.day ?? 0).\(dateComponents.month ?? 0).\(dateComponents.year ?? 0) \(dateComponents.hour ?? 0):\(dateComponents.minute ?? 0):\(dateComponents.second ?? 0)"
        } else {
            infoLabel.text = nil
        }
    }
    
}

// MARK: delegate protocol
protocol DescriptionButtonCellDelegateProtocol: AnyObject {
    func pressTaskDescriptionOpenButton()
}
