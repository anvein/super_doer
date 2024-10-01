
import UIKit

/// Кнопка-ячейка для "Описания задачи"
final class DescriptionButtonCell: UITableViewCell {
    
    enum State {
        case empty
        case textFilled
    }
    
    static let emptyHeight = 135
    static let maxHeight = 172
    
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
        selectedBackgroundView?.backgroundColor = .Common.lightBlueBg

        // setup content views
        mainTextLabel.translatesAutoresizingMaskIntoConstraints = false
        mainTextLabel.font = mainTextLabel.font.withSize(16)
        mainTextLabel.numberOfLines = 6
        mainTextLabel.lineBreakMode = .byTruncatingTail
        
        infoLabel.translatesAutoresizingMaskIntoConstraints = false
        infoLabel.numberOfLines = 1
        infoLabel.font = infoLabel.font.withSize(14)
        infoLabel.textColor = .Text.gray
        
        openButton.translatesAutoresizingMaskIntoConstraints = false
        openButton.titleLabel?.font = openButton.titleLabel?.font.withSize(14)
        openButton.setTitleColor(.Text.blue, for: .normal)
        openButton.setTitleColor(.Text.black, for: .selected)
        openButton.setTitle("Открыть", for: .normal)
        openButton.addTarget(self, action: #selector(pressOpenButton), for: .touchUpInside)
        
        bottomSeparator.translatesAutoresizingMaskIntoConstraints = false
        bottomSeparator.backgroundColor = .Common.lightGraySeparator
        
        configureCellForState(state)
    }
    
    private func configureCellForState(_ state: State) {
        switch state {
        case .empty:
            mainTextLabel.text = "Добавить заметку"
            mainTextLabel.textColor = .Text.gray
            mainTextLabel.font = UIFont.systemFont(ofSize: 16)
            
            infoLabel.text = nil
            infoLabel.isHidden = true
            openButton.isHidden = true
            
//            contentViewHeightConstraint?.isActive = true
            
        case .textFilled:
            infoLabel.isHidden = false
            infoLabel.text = "Обновлено: несколько секунд назад"
            
            mainTextLabel.textColor = .Text.black
            mainTextLabel.font = UIFont.systemFont(ofSize: 16)
            
            openButton.isHidden = false
        }
    }
    
    
    private func setupConstraints() {
        // contentView
//        contentView.heightAnchor.constraint(equalToConstant: DescriptionButtonCell.emptyHeight.cgFloat)
//            .isActive = true
        
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
        delegate?.didTapTaskDescriptionOpenButton()
    }
    
    
    // MARK: methods helpers
    // TODO: пока костыль + текст надо изменять только при помощи этого метода
    // TODO: надо придумать, как отслеживать изменение mainTextLabel.text и изменять state при изменении mainTextLabel.text
    func fillFrom(_ cellViewModel: DescriptionCellViewModel) {
        fillContent(attributedText: cellViewModel.content)
        fillInfoLabel(dateUpdated: cellViewModel.updatedAt)
    }
    
    private func fillContent(attributedText: NSAttributedString?) {
        if attributedText == nil || attributedText?.length == 0 {
            mainTextLabel.attributedText = nil
            
            state = .empty
        } else {
            mainTextLabel.attributedText = attributedText
            
            state = .textFilled
        }
        
        configureCellForState(state)
    }
    
    private func fillInfoLabel(dateUpdated: Date?) {
        if let fillDateUpdated = dateUpdated {
            let dateFormatter = DateFormatter()
            dateFormatter.locale = Locale(identifier: "ru_RU")
            dateFormatter.dateFormat = "EEEEEE, d MMMM y HH:mm:ss"
            
            infoLabel.text = "Обновлено: \(dateFormatter.string(from: fillDateUpdated))"
        } else {
            infoLabel.text = nil
        }
    }
    
}

// MARK: - DescriptionButtonCellDelegateProtocol

protocol DescriptionButtonCellDelegateProtocol: AnyObject {
    func didTapTaskDescriptionOpenButton()
}
