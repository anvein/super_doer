
import UIKit

/// Базовый класс для "кнопки-ячейки" в таблице на странице "просмотра / редактирования задачи"
class TaskDetailBaseButtonCell: UITableViewCell {
    class var identifier: String {
        return "TaskDetailBaseButtonCell"
    }
    
    class var rowHeight: Int {
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

    weak var delegate: TaskDetailBaseButtonCellDelegate?
    
    
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
        actionButton.tintColor = .Text.gray
        
        if showTopSeparator {
            topSeparator.translatesAutoresizingMaskIntoConstraints = false
            topSeparator.backgroundColor = .Common.lightGraySeparator
        }
        
        if showBottomSeparator {
            bottomSeparator.translatesAutoresizingMaskIntoConstraints = false
            bottomSeparator.backgroundColor = .Common.lightGraySeparator
        }
    }
    
    func setupConstraints() {
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
        actionButton.addTarget(
            self,
            action: #selector(handleTapActionButton(actionButton:)),
            for: .touchUpInside
        )
    }
    
    func setupSelectedBackground() {
        let selectedBgView = UIView()
        
        selectedBgView.backgroundColor = .Common.lightBlueBg
        selectedBackgroundView = selectedBgView
    }
    
    
    // MARK: methods handlers
    @objc func handleTapActionButton(actionButton: UIButton) {
        delegate?.didTapTaskDetailCellActionButton(
            cellIdentifier: Self.identifier,
            cell: self
        )
    }
    
    
    // MARK: methods helpers
    func createActionButtonImage() -> UIImage? {
        let symbolConfig = UIImage.SymbolConfiguration(pointSize: 12, weight: .regular)
        
        return UIImage(systemName: "xmark")?
            .withConfiguration(symbolConfig)
            .withRenderingMode(.alwaysTemplate)
    }
}


// MARK: delegate protocol
protocol TaskDetailBaseButtonCellDelegate: AnyObject {
    /// Была нажата кнопка "действия" в ячейке
    func didTapTaskDetailCellActionButton(cellIdentifier: String, cell: UITableViewCell)
}
