import UIKit
import SnapKit
import RxSwift
import RxRelay
import RxCocoa

final class TasksListVCView: UIView {

    enum Answer {
        case onSelectTask(IndexPath)
        case onTapIsDoneButton(IndexPath)
        case onTapIsPriorityButton(IndexPath)
        case onSelectDeleteTasks([IndexPath])
        case onConfirmCreateTask(TaskCreateData)

        case onNavigationTitleVisibleChange(Bool)
    }

    weak var tableDataSource: TaskListTableDataSource?

    // MARK: - Services

    private let symbolCreator: SymbolCreatorService

    // MARK: - Rx

    private let disposeBag = DisposeBag()

    private let answerRelay: PublishRelay<Answer> = .init()
    var answerSignal: Signal<Answer> {
        answerRelay.asSignal()
    }

    var sectionTitleBinder: Binder<String> {
        Binder(self) { view, text in
            view.tableHeaderLabel.text = text
        }
    }

    // MARK: - Views Accessors

    var hasTasksInTable: Bool {
        return tasksTableView.numberOfRows(inSection: 0) > 0 || tasksTableView.numberOfSections > 0
    }

    // MARK: - Subviews

    private let tableHeaderLabel = UILabel()
    private let tasksTableView = UITableView(frame: .zero, style: .grouped)
    private let tableContainerView = UIView()

    private lazy var taskCreatePanel = TaskCreateBottomPanel()
    private let backgroundImageView = UIImageView()

    // MARK: - Constraints

    private var panelHeightConstraint: Constraint?
    private var panelTopPaddingConstraint: Constraint?
    private var panelHorizontalPaddingsConstraint: Constraint?

    // MARK: - State / Rx

    private let isShowNavigationTitleRelay = BehaviorRelay(value: true)

    // MARK: - Init

    init(symbolCreator: SymbolCreatorService = .init()) {
        self.symbolCreator = symbolCreator
        super.init(frame: UIWindow.current?.bounds ?? .zero)

        setupHierarchy()
        setupView()
        setupBindings()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - Update view

    func reloadTableData() {
        tasksTableView.reloadData()
    }

    func updateTasksTable(for updateEvent: TaskListTableUpdateEvent) {
        switch updateEvent {
        case .beginUpdates:
            tasksTableView.beginUpdates()

        case .endUpdates:
            tasksTableView.endUpdates()

        case .insertTask(let indexPath):
            tasksTableView.insertRows(at: [indexPath], with: .automatic)

        case .deleteTask(let indexPath):
            tasksTableView.deleteRows(at: [indexPath], with: .automatic)

        case .updateTask(let indexPath, let taskCellVM):
            guard let cell = tasksTableView.cellForRow(at: indexPath) as? StandartTaskTableCell else { return }
            cell.fillFrom(viewModel: taskCellVM)

        case .moveTask(let fromIndexPath, let toIndexPath, let taskCellVM):
            guard let cell = tasksTableView.cellForRow(at: fromIndexPath) as? StandartTaskTableCell else { return }
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

}

private extension TasksListVCView {

    // MARK: - Setup

    func setupView() {
        tableHeaderLabel.textColor = .white
        tableHeaderLabel.font = .systemFont(ofSize: 32, weight: .bold)

        tasksTableView.verticalScrollIndicatorInsets.right = -9
        tasksTableView.clipsToBounds = false
        tasksTableView.backgroundColor = nil
        tasksTableView.scrollsToTop = true
        tasksTableView.separatorStyle = .none
        tasksTableView.estimatedRowHeight = UITableView.automaticDimension
        tasksTableView.rowHeight = UITableView.automaticDimension
        tasksTableView.dragInteractionEnabled = true
        tasksTableView.tableHeaderView = tableHeaderLabel

        tableContainerView.clipsToBounds = true
        tableContainerView.layer.zPosition = 1

        tasksTableView.register(StandartTaskTableCell.self, forCellReuseIdentifier: StandartTaskTableCell.className)
        tasksTableView.delegate = self
        tasksTableView.dataSource = self
        tasksTableView.dragDelegate = self
        tasksTableView.dropDelegate = self

        taskCreatePanel.textFieldPlaceholder = "Создать задачу"
        taskCreatePanel.layer.zPosition = 2

        backgroundImageView.image = .bgList
        backgroundImageView.contentMode = .scaleAspectFill
        backgroundImageView.clipsToBounds = true
        backgroundImageView .layer.zPosition = 0
    }

    func setupHierarchy() {
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

        let panelState = taskCreatePanel.currentStateValue
        taskCreatePanel.snp.makeConstraints {
            $0.bottom.equalTo(keyboardLayoutGuide.snp.top)
            $0.centerX.equalToSuperview()
            panelHeightConstraint = $0.height.equalTo(panelState.panelHeight).constraint
            panelTopPaddingConstraint = $0.top.equalTo(tasksTableView.snp.bottom).offset(panelState.panelSidesPadding).constraint
            panelHorizontalPaddingsConstraint = $0.horizontalEdges.equalToSuperview().inset(panelState.panelSidesPadding).constraint
        }
    }

    func setupBindings() {
        taskCreatePanel.answerSignal
            .emit { [weak self] answer in
                self?.handleTaskCreatePanelAnswer(answer)
            }
            .disposed(by: disposeBag)

        isShowNavigationTitleRelay
            .map { .onNavigationTitleVisibleChange($0) }
            .bind(to: answerRelay)
            .disposed(by: disposeBag)

        isShowNavigationTitleRelay
            .subscribe(onNext: { [weak self] isShowNavigationTitle in
                self?.setTableHeaderVisible(!isShowNavigationTitle)
            })
            .disposed(by: disposeBag)
    }

    // MARK: - Update view

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

    // MARK: - Actions Handlers

    func handleTableCellAnswer(_ action: StandartTaskTableCell.Answer) {
        switch action {
        case .onTapIsDoneButton(let indexPath):
            answerRelay.accept(.onTapIsDoneButton(indexPath))

        case .onTapIsPriorityButton(let indexPath):
            answerRelay.accept(.onTapIsPriorityButton(indexPath))
        }
    }

    private func handleTaskCreatePanelAnswer(_ answer: TaskCreateBottomPanel.Answer) {
        switch answer {
        case .onChangedState(let newState):
            updatePanelForState(newState)

        case .onConfirmCreateTask(let taskData):
            answerRelay.accept(.onConfirmCreateTask(taskData))
        }
    }

}

// MARK: - UITableViewDataSource

extension TasksListVCView: UITableViewDataSource {

    func numberOfSections(in tableView: UITableView) -> Int {
        return tableDataSource?.getSectionsCount() ?? 2
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return tableDataSource?.getCountRowsInSection(with: section) ?? 1
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(
            withIdentifier: StandartTaskTableCell.className
        ) as? StandartTaskTableCell else { return .init() }

        if let cellVM = tableDataSource?.getCellViewModel(for: indexPath) {
            cell.fillFrom(viewModel: cellVM)
            cell.isLast = tableView.numberOfRows(inSection: indexPath.section) - 1 == indexPath.row

            cell.actionSignal.emit(onNext: { [weak self] action in
                self?.handleTableCellAnswer(action)
            })
            .disposed(by: cell.externalDisposeBag)
        }

        return cell
    }
}

// MARK: - UITableViewDelegate

extension TasksListVCView: UITableViewDelegate {

    // MARK: Select row

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        answerRelay.accept(.onSelectTask(indexPath))
        tableView.deselectRow(at: indexPath, animated: true)
    }

    // MARK: Swipe actions

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
            self?.answerRelay.accept(.onSelectDeleteTasks([indexPath]))
            completionHandler(false)
        }
        let symbolConfig = UIImage.SymbolConfiguration(pointSize: 13, weight: .bold)
        deleteAction.image = UIImage(systemName: "trash", withConfiguration: symbolConfig)

        return UISwipeActionsConfiguration(actions: [deleteAction])
    }

    func tableView(_ tableView: UITableView, leadingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        var actions: [UIContextualAction] = []

//        let cellVM = viewModel.getTasksTableViewCellVM(forIndexPath: indexPath)
//        var symbolImage: UIImage? = nil
//        if cellVM.isInMyDay {
//            symbolImage = symbolCreator.combineSymbols(symbolName1: "sun.max", symbolName2: "line.diagonal", pointSize: 15, weight1: .bold)
//            symbolImage = symbolImage?.withTintColor(.white, renderingMode: .alwaysOriginal)
//        } else {
//            let symbolConfig = UIImage.SymbolConfiguration(pointSize: 13, weight: .bold)
//            symbolImage = UIImage(systemName: "sun.max")?.withConfiguration(symbolConfig)
//        }
//
//        if let symbolImage {
//            let action = UIContextualAction(
//                style: .normal,
//                title: "Мой день"
//            ) { [viewModel] _, _, completionHandler in
//                    viewModel.switchTaskFieldInMyDayWith(indexPath: indexPath)
//                    completionHandler(true)
//                }
//            action.backgroundColor = .systemOrange
//            action.image = symbolImage
//
//            actions.append(action)
//        }

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
//        viewModel.moveTasksInCurrentList(fromPath: sourceIndexPath, to: destinationIndexPath)
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
        let isShowValue = isShowNavigationTitleRelay.value

        if offset >= headerHeight && !isShowValue {
            isShowNavigationTitleRelay.accept(true)
        } else if offset < headerHeight && isShowValue {
            isShowNavigationTitleRelay.accept(false)
        }
    }
}
