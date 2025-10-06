
import UIKit
import SnapKit
import RxSwift

final class TasksListVCView: UIView {

    private let disposeBag = DisposeBag()

    private var viewModel: TasksListViewModelType

    weak var delegate: TasksListVCViewDelegate?

    // MARK: - Services

    private let symbolCreator: SymbolCreatorService

    // MARK: - Views Accessors

    var hasTasksInTable: Bool {
        return tasksTableView.numberOfRows(inSection: 0) > 0 || tasksTableView.numberOfSections > 0
    }

    // MARK: - Subviews

    private let tableHeaderLabel: UILabel = {
        let headerLabel = UILabel()
        headerLabel.textColor = .white
        headerLabel.font = .systemFont(ofSize: 32, weight: .bold)
        return headerLabel
    }()

    private lazy var tasksTableView: UITableView = {
        $0.verticalScrollIndicatorInsets.right = -9
        $0.clipsToBounds = false
        $0.backgroundColor = nil
        $0.scrollsToTop = true
        $0.separatorStyle = .none
        $0.estimatedRowHeight = UITableView.automaticDimension
        $0.rowHeight = UITableView.automaticDimension
        $0.dragInteractionEnabled = true
        $0.tableHeaderView = tableHeaderLabel

        $0.register(StandartTaskTableViewCell.self, forCellReuseIdentifier: StandartTaskTableViewCell.className)
        $0.delegate = self
        $0.dataSource = self
        $0.dragDelegate = self
        $0.dropDelegate = self
        return $0
    }(UITableView(frame: .zero, style: .grouped))

    private let tableContainerView: UIView = {
        $0.clipsToBounds = true
        $0.layer.zPosition = 1
        return $0
    }(UIView())

    private lazy var taskCreatePanel: TaskCreateBottomPanel = {
        $0.textFieldPlaceholder = "Создать задачу"
        $0.layer.zPosition = 2
        $0.delegate = self
        return $0
    }(TaskCreateBottomPanel())

    private let backgroundImageView = {
        $0.contentMode = .scaleAspectFill
        $0.clipsToBounds = true
        $0.layer.zPosition = 0
        return $0
    }(UIImageView(image: .bgList))

    // MARK: - Constraints

    private var panelHeightConstraint: Constraint?
    private var panelTopPaddingConstraint: Constraint?
    private var panelHorizontalPaddingsConstraint: Constraint?

    // MARK: - State

    private var isShowNavigationTitle: Bool = true {
        willSet {
            guard isShowNavigationTitle != newValue else { return }
            delegate?.tasksListVCViewNavigationTitleDidChange(isVisible: newValue)
            setTableHeaderVisible(!newValue)
        }
    }

    // MARK: - Init

    init(
        viewModel: TasksListViewModelType,
        symbolCreator: SymbolCreatorService = .init()
    ) {
        self.symbolCreator = symbolCreator
        self.viewModel = viewModel
        super.init(frame: UIWindow.current?.bounds ?? .zero)

        setupSubviewsLayout()
        setupBindings()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - Update view

    func reloadTableData() {
        tasksTableView.reloadData()
    }

}

private extension TasksListVCView {

    // MARK: - Setup

    func setupSubviewsLayout() {
        addSubviews(
            tableContainerView,
            backgroundImageView,
            taskCreatePanel
        )
        tableContainerView.addSubview(tasksTableView)

        backgroundImageView.snp.makeConstraints {
            $0.edges.equalToSuperview()
        }

        tableContainerView.snp.makeConstraints {
            $0.top.equalTo(safeAreaLayoutGuide)
            $0.horizontalEdges.equalToSuperview()
        }

        tasksTableView.snp.makeConstraints {
            $0.verticalEdges.equalToSuperview()
            $0.horizontalEdges.equalToSuperview().inset(8)
        }

        let panelState = taskCreatePanel.currentState
        taskCreatePanel.snp.makeConstraints {
            $0.bottom.equalTo(keyboardLayoutGuide.snp.top)
            $0.centerX.equalToSuperview()
            panelHeightConstraint = $0.height.equalTo(panelState.panelHeight).constraint
            panelTopPaddingConstraint = $0.top.equalTo(tasksTableView.snp.bottom).offset(panelState.panelSidesPadding).constraint
            panelHorizontalPaddingsConstraint = $0.horizontalEdges.equalToSuperview().inset(panelState.panelSidesPadding).constraint
        }
    }

    func setupBindings() {
        guard let viewModel = viewModel as? TasksListViewModel else { return }

        // VM -> V
        viewModel.sectionTitleDriver
            .drive(onNext: { [weak self] title in
                self?.setTableHeader(title: title)
            })
            .disposed(by: disposeBag)

        viewModel.tableUpdateEventsSignal
            .emit(onNext: { [weak self] event in
                self?.updateTasksTableFor(updateType: event)
            })
            .disposed(by: disposeBag)
    }

    func updateTasksTableFor(updateType: TasksListViewModel.TableUpdateEvent) {
        switch updateType {
        case .beginUpdates:
            tasksTableView.beginUpdates()

        case .endUpdates:
            tasksTableView.endUpdates()

        case .insertTask(let indexPath):
            tasksTableView.insertRows(at: [indexPath], with: .automatic)

        case .deleteTask(let indexPath):
            tasksTableView.deleteRows(at: [indexPath], with: .automatic)

        case .updateTask(let indexPath, let taskCellVM):
            guard let cell = tasksTableView.cellForRow(at: indexPath) as? StandartTaskTableViewCell else { return }
            cell.fillFrom(viewModel: taskCellVM)

        case .moveTask(let fromIndexPath, let toIndexPath, let taskCellVM):
            guard let cell = tasksTableView.cellForRow(at: fromIndexPath) as? StandartTaskTableViewCell else { return }
            cell.fillFrom(viewModel: taskCellVM)
            tasksTableView.moveRow(at: fromIndexPath, to: toIndexPath)

        case .insertSection(let sectionId):
            tasksTableView.insertSections(
                .init(integer: sectionId),
                with: .middle
            )

        case .deleteSection(let sectionId):
            tasksTableView.deleteSections(
                .init(integer: sectionId),
                with: .middle
            )
        }
    }

    // MARK: - Update view

    func setTableHeader(title: String) {
        tableHeaderLabel.text = title
        tableHeaderLabel.sizeToFit()
        tableHeaderLabel.frame = .init(
            origin: .zero,
            size: .init(
                width: tableHeaderLabel.frame.width,
                height: tableHeaderLabel.frame.height + 10
            )
        )
    }

    func setTableHeaderVisible(_ visible: Bool) {
        guard let tableHeader = tasksTableView.tableHeaderView else { return }

        UIView.transition(
            with: tableHeader,
            duration: visible ? 0.2 : 0.1,
            options: [.transitionCrossDissolve]
        ) { [tableHeader] in
            tableHeader.alpha = visible ? 1 : 0
        }
    }

    func updatePanelForState(_ newState: TaskCreateBottomPanel.State) {
        panelHeightConstraint?.update(offset: newState.panelHeight)
        panelTopPaddingConstraint?.update(offset: newState.panelSidesPadding)
        panelHorizontalPaddingsConstraint?.update(inset: newState.panelSidesPadding)

        UIView.animate(withDuration: 0.3) { [weak self] in
            self?.layoutIfNeeded()
        }
    }

}

// MARK: - UITableViewDataSource

extension TasksListVCView: UITableViewDataSource {

    func numberOfSections(in tableView: UITableView) -> Int {
        return viewModel.getSectionsCount()
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return viewModel.getTasksCountIn(section: section)
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(
            withIdentifier: StandartTaskTableViewCell.className
        ) as? StandartTaskTableViewCell else { return .init() }

        let cellVM = viewModel.getTaskTableViewCellViewModel(forIndexPath: indexPath)
        
        cell.fillFrom(viewModel: cellVM)
        cell.isLast = tableView.numberOfRows(inSection: indexPath.section) == indexPath.row + 1
        cell.delegate = self

        return cell
    }
}

// MARK: - UITableViewDelegate

extension TasksListVCView: UITableViewDelegate {

    // MARK: Select row

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        guard let selectedTaskVM = viewModel.getTaskDetailViewModel(forIndexPath: indexPath) else { return }
        delegate?.tasksListVCViewDidSelectTask(viewModel: selectedTaskVM)

        tableView.deselectRow(at: indexPath, animated: true)
    }

    // MARK: Swipes actions

    func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        // TODO: доработать, чтобы SwipeAction отображались внутри ячейки (или были со скругленными краями)
        let cell = tableView.cellForRow(at: indexPath)
        guard let _ = cell?.contentView else {
            return nil
        }

        let deleteAction = UIContextualAction(
            style: .destructive,
            title: "Удалить"
        ) { [weak self] _, _, completionHandler in
            self?.delegate?.tasksListVCViewDidSelectDeleteTask(tasksIndexPaths: [indexPath])
            completionHandler(false)
        }
        let symbolConfig = UIImage.SymbolConfiguration(pointSize: 13, weight: .bold)
        deleteAction.image = UIImage(systemName: "trash", withConfiguration: symbolConfig)

        return UISwipeActionsConfiguration(actions: [deleteAction])
    }

    func tableView(_ tableView: UITableView, leadingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        var actions: [UIContextualAction] = []

        let cellVM = viewModel.getTaskTableViewCellViewModel(forIndexPath: indexPath)
        var symbolImage: UIImage? = nil
        if cellVM.isInMyDay {
            symbolImage = symbolCreator.combineSymbols(symbolName1: "sun.max", symbolName2: "line.diagonal", pointSize: 15, weight1: .bold)
            symbolImage = symbolImage?.withTintColor(.white, renderingMode: .alwaysOriginal)
        } else {
            let symbolConfig = UIImage.SymbolConfiguration(pointSize: 13, weight: .bold)
            symbolImage = UIImage(systemName: "sun.max")?.withConfiguration(symbolConfig)
        }

        if let symbolImage {
            let action = UIContextualAction(
                style: .normal,
                title: "Мой день"
            ) { [viewModel] _, _, completionHandler in
                    viewModel.switchTaskFieldInMyDayWith(indexPath: indexPath)
                    completionHandler(true)
                }
            action.backgroundColor = .systemOrange
            action.image = symbolImage

            actions.append(action)
        }

        return UISwipeActionsConfiguration(actions: actions)
    }

    // MARK: delete row

    func tableView(_ tableView: UITableView, editingStyleForRowAt indexPath: IndexPath) -> UITableViewCell.EditingStyle {
        if !tableView.isEditing {
            return .delete
        }

        return .none
    }

//    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
//        if editingStyle == .delete {
//            tasksArray.remove(at: indexPath.row)
//            tableView.deleteRows(at: [indexPath], with: .fade)
//        }
//    }

    func tableView(_ tableView: UITableView, shouldIndentWhileEditingRowAt indexPath: IndexPath) -> Bool {
        return false
    }


    // MARK: Move row

    func tableView(_ tableView: UITableView, moveRowAt sourceIndexPath: IndexPath, to destinationIndexPath: IndexPath) {
        viewModel.moveTasksInCurrentList(fromPath: sourceIndexPath, to: destinationIndexPath)
    }

    func tableView(_ tableView: UITableView, canMoveRowAt indexPath: IndexPath) -> Bool {
        return true
    }

    // MARK: Highlight rows

    func tableView(_ tableView: UITableView, didUnhighlightRowAt indexPath: IndexPath) {
        let cell = tableView.cellForRow(at: indexPath) as? HighlightableCell
        cell?.setCellHighlighted(false)
    }

    func tableView(_ tableView: UITableView, didHighlightRowAt indexPath: IndexPath) {
        let cell = tableView.cellForRow(at: indexPath) as? HighlightableCell
        cell?.setCellHighlighted(true)
    }
}

// MARK: - UITableViewDragDelegate

extension TasksListVCView: UITableViewDragDelegate {
    func tableView(_ tableView: UITableView, itemsForBeginning session: UIDragSession, at indexPath: IndexPath) -> [UIDragItem] {
        let dragItem = UIDragItem(itemProvider: .init())
        dragItem.localObject = indexPath
        return [dragItem]
    }

    func tableView(_ tableView: UITableView, dragSessionIsRestrictedToDraggingApplication session: UIDragSession) -> Bool {
        return true
    }

    func tableView(_ tableView: UITableView, dragPreviewParametersForRowAt indexPath: IndexPath) -> UIDragPreviewParameters? {
        guard let cell = tableView.cellForRow(at: indexPath) else { return nil }

        let preview = UIDragPreviewParameters()
        preview.shadowPath = UIBezierPath(
            roundedRect: cell.bounds.insetBy(dx: 0, dy: 0),
            cornerRadius: 8
        )
        preview.visiblePath = UIBezierPath(
            roundedRect: cell.bounds.insetBy(dx: 0, dy: 0),
            cornerRadius: 8
        )
        return preview
    }
}

// MARK: - UITableViewDropDelegate

extension TasksListVCView: UITableViewDropDelegate {
    func tableView(_ tableView: UITableView, dropSessionDidEnter session: any UIDropSession) {
    }

    func tableView(_ tableView: UITableView, dropSessionDidExit session: any UIDropSession) {
    }

    func tableView(
        _ tableView: UITableView,
        dropSessionDidUpdate session: UIDropSession,
        withDestinationIndexPath destinationIndexPath: IndexPath?
    ) -> UITableViewDropProposal {
        if let item = session.items.first,
           let fromIndexPath = item.localObject as? IndexPath,
           let toIndexPath = destinationIndexPath,
           fromIndexPath.section == toIndexPath.section,
           toIndexPath.row <= tableView.numberOfRows(inSection: 0) {
            return .init(operation: .move, intent: .insertAtDestinationIndexPath)
        } else {
            return .init(operation: .cancel)
        }
    }

    func tableView(_ tableView: UITableView, performDropWith coordinator: UITableViewDropCoordinator) {


    }

    func tableView(_ tableView: UITableView, dropSessionDidEnd session: UIDropSession) {
    }

    func tableView(_ tableView: UITableView, dropPreviewParametersForRowAt indexPath: IndexPath) -> UIDragPreviewParameters? {
        guard let cell = tableView.cellForRow(at: indexPath) else { return nil }

        let preview = UIDragPreviewParameters()
        preview.visiblePath = UIBezierPath(
            roundedRect: cell.bounds.insetBy(dx: 0, dy: 0),
            cornerRadius: 8
        )
        return preview
    }
}

// MARK: - UIScrollViewDelegate

extension TasksListVCView: UIScrollViewDelegate {
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        let offset = scrollView.contentOffset.y

        let headerHeight = (tasksTableView.tableHeaderView?.bounds.height ?? 0) / 3

        if offset >= headerHeight && !isShowNavigationTitle {
            isShowNavigationTitle = true
        } else if offset < headerHeight && isShowNavigationTitle {
            isShowNavigationTitle = false
        }
    }
}

// MARK: - CreateTaskBottomPanelDelegate

extension TasksListVCView: TaskCreateBottomPanelDelegate {
    func taskCreateBottomPanelDidTapCreateButton(title: String, inMyDay: Bool, reminderDateTime: Date?, deadlineAt: Date?, description: String?) {
        let title = title.trimmingCharacters(in: .whitespaces)
        if !title.isEmpty {
            viewModel.createNewTaskInCurrentSectionWith(
                title: title,
                inMyDay: inMyDay,
                reminderDateTime: reminderDateTime,
                deadlineAt: deadlineAt,
                description: description
            )
        }
    }

    func taskCreateBottomPanelDidChangedState(newState: TaskCreateBottomPanel.State) {
        updatePanelForState(newState)
    }

}
// MARK: - StandartTaskTableViewCellDelegate

extension TasksListVCView: StandartTaskTableViewCellDelegate {

    func standartTaskCellDidTapIsDoneButton(indexPath: IndexPath) {
        viewModel.switchTaskFieldIsCompletedWith(indexPath: indexPath)
    }

    func standartTaskCellDidTapIsPriorityButton(indexPath: IndexPath) {
        viewModel.switchTaskFieldIsPriorityWith(indexPath: indexPath)
    }

}
