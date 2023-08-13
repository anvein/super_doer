
import UIKit

/// Базовый класс для "кнопки-ячейки" в таблице на странице "редактирования задачи"
class TaskViewBaseButtonCell: UITableViewCell {
    class var identifier: String {
        get {
            return "TaskViewBaseButtonCell"
        }
    }
    
    // MARK: base views
    let leftImageView = UIImageView()
    let actionButton = UIButton()
    
    /// Показывать ли верхний разделитель (переопределять для конфигурирования)
    // TODO: переделать на конфирурируемое свойство
    var showTopSeparator: Bool {
        get {
            return false
        }
    }
    lazy var topSeparator = UIView()
    
    /// Показывать ли нижний разделитель (переопределять для конфигурирования)
    // TODO: переделать на конфирурируемое свойство в init
    var showBottomSeparator: Bool {
        get {
            return false
        }
    }
    lazy var bottomSeparator = UIView()

    
    // MARK: init
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        addSubviews()
        setupViews()
        setupConstraints()
        setupHandlers()
        
        // TODO: переделать на конфирурируемые свойства showTopSeparator и showBottomSeparator
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: setup methods
    func addSubviews() {
        contentView.addSubview(leftImageView)
        contentView.addSubview(actionButton)
        
        if showTopSeparator {
            contentView.addSubview(topSeparator)
        }
        
        if showBottomSeparator {
            contentView.addSubview(bottomSeparator)
        }
    }
    
    func setupViews() {
        // setup cell
        backgroundColor = nil
        backgroundView = UIView()
        
        setupSelectedBackground()
        
        // setup content subviews
        leftImageView.translatesAutoresizingMaskIntoConstraints = false
        leftImageView.image = createLeftButtonImage()
        
        actionButton.translatesAutoresizingMaskIntoConstraints = false
        actionButton.setImage(createActionButtonImage(), for: .normal)
        actionButton.tintColor = InterfaceColors.textGray
        
        if showTopSeparator {
            topSeparator.translatesAutoresizingMaskIntoConstraints = false
            topSeparator.backgroundColor = InterfaceColors.TaskViewButtonCell.separator
        }
        
        if showBottomSeparator {
            bottomSeparator.translatesAutoresizingMaskIntoConstraints = false
            bottomSeparator.backgroundColor = InterfaceColors.TaskViewButtonCell.separator
        }
    }
    
    func setupConstraints() {
        // leftImageView
        NSLayoutConstraint.activate([
            leftImageView.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
            leftImageView.centerXAnchor.constraint(equalTo: contentView.leftAnchor, constant: 32)
        ])
        
        // actionButton
        NSLayoutConstraint.activate([
            actionButton.rightAnchor.constraint(equalTo: contentView.rightAnchor),
            actionButton.heightAnchor.constraint(equalTo: contentView.heightAnchor),
            actionButton.widthAnchor.constraint(equalToConstant: 58)
        ])
        
        // topSeparator
        if showTopSeparator {
            NSLayoutConstraint.activate([
                topSeparator.topAnchor.constraint(equalTo: topAnchor),
                topSeparator.leftAnchor.constraint(equalTo: leftAnchor, constant: 16),
                topSeparator.rightAnchor.constraint(equalTo: rightAnchor, constant: -16),
                topSeparator.heightAnchor.constraint(equalToConstant: 1),
            ])
        }
        
        // bottomSeparator
        if showBottomSeparator {
            NSLayoutConstraint.activate([
                bottomSeparator.bottomAnchor.constraint(equalTo: bottomAnchor),
                bottomSeparator.leftAnchor.constraint(equalTo: leftAnchor, constant: 16),
                bottomSeparator.rightAnchor.constraint(equalTo: rightAnchor, constant: -16),
                bottomSeparator.heightAnchor.constraint(equalToConstant: 1),
            ])
        }
    }
    
    func setupHandlers() {
        
    }
    
    func setupSelectedBackground() {
        let selectedBgView = UIView()
        
        selectedBgView.backgroundColor = InterfaceColors.controlsLightBlueBg
        selectedBackgroundView = selectedBgView
    }
    
    // MARK: methods helpers
    func createLeftButtonImage() -> UIImage? {
        return nil
    }
    
    func createActionButtonImage() -> UIImage? {
        let symbolConfig = UIImage.SymbolConfiguration(pointSize: 12, weight: .regular)
        
        return UIImage(systemName: "xmark")?
            .withConfiguration(symbolConfig)
            .withRenderingMode(.alwaysTemplate)
    }
}
