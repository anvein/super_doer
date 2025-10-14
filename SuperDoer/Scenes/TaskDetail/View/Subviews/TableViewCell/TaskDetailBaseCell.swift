
import UIKit
import SnapKit

/// Базовый класс для "кнопки-ячейки" в таблице на странице "просмотра / редактирования задачи"
class TaskDetailBaseCell: UITableViewCell {

    weak var delegate: TaskDetailDataBaseCellDelegate?

    // MARK: - Settings

    class var rowHeight: Int { 58 }

    /// Показывать ли верхний разделитель (переопределять для конфигурирования)
    var showTopSeparator: Bool {
        return false
    }

    /// Показывать ли нижний разделитель (переопределять для конфигурирования)
    var showBottomSeparator: Bool {
        return false
    }

    // MARK: - Subviews

    let actionButton: UIButton = .init()

    private lazy var topSeparator: UIView = .init()
    private lazy var bottomSeparator: UIView = .init()

    // MARK: - Init
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        addSubviews()
        setupSubviews()
        setupConstraints()
        setupHandlers()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
    // MARK: - Subviews

    /// Override if needed
    func addSubviews() {
        contentView.addSubview(actionButton)
        
        if showTopSeparator {
            contentView.addSubview(topSeparator)
        }
        
        if showBottomSeparator {
            contentView.addSubview(bottomSeparator)
        }
    }

    /// Override if needed
    func setupSubviews() {
        // setup cell
        backgroundColor = nil
        backgroundView = UIView()
        
        setupSelectedBackground()
        
        // setup content subviews
        actionButton.setImage(createActionButtonImage(), for: .normal)
        actionButton.tintColor = .Text.gray
        
        if showTopSeparator {
            topSeparator.backgroundColor = .Common.lightGraySeparator
        }
        
        if showBottomSeparator {
            bottomSeparator.backgroundColor = .Common.lightGraySeparator
        }
    }

    /// Override if needed
    func setupConstraints() {
        actionButton.snp.makeConstraints {
            $0.trailing.verticalEdges.equalToSuperview()
            $0.width.equalTo(58)
        }

        if showTopSeparator {
            topSeparator.snp.makeConstraints {
                $0.top.equalToSuperview()
                $0.horizontalEdges.equalToSuperview().inset(16)
                $0.height.equalTo(0.5)
            }
        }

        if showBottomSeparator {
            bottomSeparator.snp.makeConstraints {
                $0.bottom.equalToSuperview()
                $0.horizontalEdges.equalToSuperview().inset(16)
                $0.height.equalTo(0.5)
            }
        }
    }

    /// Override if needed
    func setupHandlers() {
        actionButton.addTarget(
            self,
            action: #selector(handleTapActionButton(actionButton:)),
            for: .touchUpInside
        )
    }

    /// Override if needed
    func setupSelectedBackground() {
        let selectedBgView = UIView()
        
        selectedBgView.backgroundColor = .Common.lightBlueBg
        selectedBackgroundView = selectedBgView
    }
    
    
    // MARK: - Actions handlers

    @objc private func handleTapActionButton(actionButton: UIButton) {
        delegate?.taskDetailDataCellDidTapActionButton(
            cellIdentifier: Self.className,
            cell: self
        )
    }
    
    // MARK: - Helpers

    func createActionButtonImage() -> UIImage? {
        let symbolConfig = UIImage.SymbolConfiguration(pointSize: 12, weight: .regular)
        
        return UIImage(systemName: "xmark")?
            .withConfiguration(symbolConfig)
            .withRenderingMode(.alwaysTemplate)
    }
}

// MARK: - TaskDetailDataBaseCellDelegate

protocol TaskDetailDataBaseCellDelegate: AnyObject {
    func taskDetailDataCellDidTapActionButton(cellIdentifier: String, cell: UITableViewCell)
}
