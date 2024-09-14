
import UIKit
import SnapKit

final class TaskListInSectionVCView: UIView {

    private var viewModel: TasksListInSectionViewModelType

    weak var delegate: TaskListInSectionVCViewDelegate?

    // MARK: - Subviews

    lazy var tasksTableView: TasksListTableView = {
        $0.clipsToBounds = false
        $0.layer.zPosition = 1
        $0.backgroundColor = nil
        $0.scrollsToTop = true
        $0.separatorStyle = .none
        $0.estimatedRowHeight = UITableView.automaticDimension
        $0.rowHeight = UITableView.automaticDimension
        $0.register(StandartTaskTableViewCell.self, forCellReuseIdentifier: StandartTaskTableViewCell.identifier)
        $0.delegate = self
        $0.dataSource = self
        $0.dragDelegate = self
        $0.dropDelegate = self
        $0.dragInteractionEnabled = true
        return $0
    }(TasksListTableView())

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

    // MARK: - Init

    init(viewModel: TasksListInSectionViewModelType) {
        self.viewModel = viewModel
        super.init(frame: UIWindow.current?.bounds ?? .zero)

        setupSubviewsLayout()
        setupBindings()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}

private extension TaskListInSectionVCView {

    // MARK: - Setup

    func setupSubviewsLayout() {
        addSubviews(
            tasksTableView,
            backgroundImageView,
            taskCreatePanel
        )

        backgroundImageView.snp.makeConstraints {
            $0.edges.equalToSuperview()
        }

        tasksTableView.snp.makeConstraints {
            $0.top.equalTo(safeAreaLayoutGuide)
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
        if let viewModel = viewModel as? TasksListInSectionViewModel {
            viewModel.tasksUpdateBinding = { [weak self] in
                // TODO: реализовать красивое удаление/перемещение/добавление задач из таблицы
                // tasksTable.deleteRows(at: tasksIndexPaths, with: .fade)
                // tasksTable.moveRow(at: sourceIndexPath, to: destinationIndexPath)
                self?.tasksTableView.reloadData()
            }
        }
    }

    // MARK: - Update view

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

extension TaskListInSectionVCView: UITableViewDataSource {

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return viewModel.getTasksCount()
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: StandartTaskTableViewCell.identifier) as! StandartTaskTableViewCell
        let taskCellViewModel = viewModel.getTaskInSectionTableViewCellViewModel(forIndexPath: indexPath)

        cell.textLabel?.text = taskCellViewModel.title
        cell.detailTextLabel?.text = taskCellViewModel.sectionTitle
        cell.isDoneButton.isOn = taskCellViewModel.isCompleted

        return cell
    }
}

// MARK: UITableViewDelegate

extension TaskListInSectionVCView: UITableViewDelegate {

    // MARK: Select row

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        guard let selectedTaskVM = viewModel.getTaskDetailViewModel(forIndexPath: indexPath) else { return }
        delegate?.taskListInSectionVCViewDidSelectTask(viewModel: selectedTaskVM)

        tableView.deselectRow(at: indexPath, animated: true)
    }

//    // MARK: Rows appearance
//
//    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
////        cell.backgroundColor = .systemPink
////        cell.backgroundView?.backgroundColor = .systemGreen
//    }


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
            self?.delegate?.taskListInSectionVCViewDidSelectDeleteTask(tasksIndexPaths: [indexPath])
            completionHandler(false)
        }
        let symbolConfig = UIImage.SymbolConfiguration(pointSize: 13, weight: .bold)
        deleteAction.image = UIImage(systemName: "trash", withConfiguration: symbolConfig)


        return UISwipeActionsConfiguration(actions: [deleteAction])
    }

    // добавление действий при свайпах
    func tableView(_ tableView: UITableView, leadingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        let action = UIContextualAction(
            style: .normal,
            title: "☀️") { action, view, completionHandler in
                print("☀️ add to my day")

                completionHandler(true)
            }
        action.backgroundColor = .systemOrange

        return UISwipeActionsConfiguration(actions: [action])
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


    // MARK: move row

    func tableView(_ tableView: UITableView, moveRowAt sourceIndexPath: IndexPath, to destinationIndexPath: IndexPath) {
        viewModel.moveTasksInCurrentList(fromPath: sourceIndexPath, to: destinationIndexPath)
    }

    func tableView(_ tableView: UITableView, canMoveRowAt indexPath: IndexPath) -> Bool {
        return true
    }


    // для реализации кастомного скрытия largeTitle при прокрутке
//    func scrollViewDidScroll(_ scrollView: UIScrollView) {
////        if viewController.tasksTable.contentOffset.y <= 0 {
////            viewController.navigationItem.largeTitleDisplayMode = .always
////        } else {
////            viewController.navigationItem.largeTitleDisplayMode = .never
////        }
////
////        viewController.navigationController?.navigationBar.setNeedsLayout()
////        viewController.view.setNeedsLayout()
////
////        UIView.animate(withDuration: 0.25, animations: {
////            self.viewController.navigationController?.navigationBar.layoutIfNeeded()
////            self.viewController.view.layoutIfNeeded()
////        })
//    }

}

// MARK: - UITableViewDragDelegate

extension TaskListInSectionVCView: UITableViewDragDelegate {
    func tableView(_ tableView: UITableView, dragSessionIsRestrictedToDraggingApplication session: UIDragSession) -> Bool {
        true
    }

    func tableView(_ tableView: UITableView, itemsForBeginning session: UIDragSession, at indexPath: IndexPath) -> [UIDragItem] {
        let item = UIDragItem(itemProvider: .init())
        item.localObject = indexPath
        return [item]
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

extension TaskListInSectionVCView: UITableViewDropDelegate {
    func tableView(_ tableView: UITableView, dropSessionDidUpdate session: UIDropSession, withDestinationIndexPath destinationIndexPath: IndexPath?) -> UITableViewDropProposal {
        if let item = session.items.first,
           let fromIndexPath = item.localObject as? IndexPath,
           let toIndexPath = destinationIndexPath,
           toIndexPath.row <= tableView.numberOfRows(inSection: 0) {
//            updateCellsAppearanceAfterMovement(from: fromIndexPath, to: toIndexPath)
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

// MARK: - CreateTaskBottomPanelDelegate

extension TaskListInSectionVCView: TaskCreateBottomPanelDelegate {
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
