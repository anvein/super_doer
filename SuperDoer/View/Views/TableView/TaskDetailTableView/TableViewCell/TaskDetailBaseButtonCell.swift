
import UIKit

/// Базовый класс для "кнопки-ячейки" в таблице на странице "просмотра / редактирования задачи"
class TaskDetailBaseButtonCell: UITableViewCell {
    class var identifier: String {
        return "TaskDetailBaseButtonCell"
    }
    
    var rowHeight: Int {
        return 58
    }

    // MARK: base views
    let actionButton = UIButton()
    
    /// Показывать ли верхний разделитель (переопределять для конфигурирования)
    // TODO: переделать на конфирурируемое свойство
    var showTopSeparator: Bool {
        return false
    }
    private lazy var topSeparator = UIView()
    
    /// Показывать ли нижний разделитель (переопределять для конфигурирования)
    // TODO: переделать на конфирурируемое свойство в init
    var showBottomSeparator: Bool {
        return false
    }
    private lazy var bottomSeparator = UIView()

    
    // MARK: init
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        addSubviews()
        setupViews()
        setupConstraints()
        setupHandlers()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: setup methods
    func addSubviews() {
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
        // contentView
        NSLayoutConstraint.activate([
            contentView.heightAnchor.constraint(equalToConstant: rowHeight.cgFloat),
        ])
        
        // actionButton
        NSLayoutConstraint.activate([
            actionButton.rightAnchor.constraint(equalTo: contentView.rightAnchor),
            actionButton.topAnchor.constraint(equalTo: contentView.topAnchor),
            actionButton.bottomAnchor.constraint(equalTo: contentView.bottomAnchor),
            actionButton.widthAnchor.constraint(equalToConstant: 58),
        ])
        
        // topSeparator
        if showTopSeparator {
            NSLayoutConstraint.activate([
                topSeparator.topAnchor.constraint(equalTo: topAnchor),
                topSeparator.leftAnchor.constraint(equalTo: leftAnchor, constant: 16),
                topSeparator.rightAnchor.constraint(equalTo: rightAnchor, constant: -16),
                topSeparator.heightAnchor.constraint(equalToConstant: 0.5),
            ])
        }
        
        // bottomSeparator
        if showBottomSeparator {
            NSLayoutConstraint.activate([
                bottomSeparator.bottomAnchor.constraint(equalTo: bottomAnchor),
                bottomSeparator.leftAnchor.constraint(equalTo: leftAnchor, constant: 16),
                bottomSeparator.rightAnchor.constraint(equalTo: rightAnchor, constant: -16),
                bottomSeparator.heightAnchor.constraint(equalToConstant: 0.5),
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
    func createActionButtonImage() -> UIImage? {
        let symbolConfig = UIImage.SymbolConfiguration(pointSize: 12, weight: .regular)
        
        return UIImage(systemName: "xmark")?
            .withConfiguration(symbolConfig)
            .withRenderingMode(.alwaysTemplate)
    }
}
