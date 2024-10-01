
import UIKit
import SnapKit

final class TaskDetailView: UIView {

    private let viewModel: TaskDetailViewModel

    // MARK: - Subviews

    private var topControlsContainerView: UIView = .init()

    private lazy var taskDoneButton: CheckboxButton = {
        $0.addTarget(self, action: #selector(didTapTaskDoneButton(sender:)), for: .touchUpInside)
        return $0
    }(CheckboxButton())

    lazy var taskTitleTextView: UITextView = {
        $0.isScrollEnabled = false
        $0.returnKeyType = .done

        $0.backgroundColor = .Common.white
        $0.textColor = .Text.black
        $0.font = UIFont.systemFont(ofSize: 22, weight: .medium)

        $0.delegate = self
        return $0
    }(UITextView())

    private lazy var isPriorityButton: StarButton = {
        $0.addTarget(self, action: #selector(didTapTaskIsPriorityButton(sender:)), for: .touchUpInside)
        return $0
    }(StarButton())

    private lazy var taskDataTableView: TaskDetailTableView =  {
        $0.dataSource = self
        $0.delegate = self
        return $0
    }(TaskDetailTableView())

    // MARK: - State

    /// Редактируемое в данный момент поле TextField
    var textFieldEditing: UITextField?

    // MARK: - Init

    init(viewModel: TaskDetailViewModel) {
        self.viewModel = viewModel

        super.init(frame: .zero)
        setup()
        setupSubvies()
        setupBindingsToViewModel()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

private extension TaskDetailView {

    // MARK: - Setup

    func setup() {
        backgroundColor = .Common.white
    }

    func setupSubvies() {
        addSubviews(topControlsContainerView, taskDataTableView)
        topControlsContainerView.addSubviews(taskDoneButton, taskTitleTextView, isPriorityButton)

        topControlsContainerView.snp.makeConstraints {
            $0.top.equalTo(self.safeAreaLayoutGuide).offset(18)
            $0.horizontalEdges.equalToSuperview()
        }

        taskDoneButton.snp.makeConstraints {
            $0.size.equalTo(26)
            $0.top.equalToSuperview().inset(9)
            $0.leading.equalToSuperview().inset(19)
        }

        taskTitleTextView.snp.makeConstraints {
            $0.verticalEdges.equalToSuperview()
            $0.leading.equalTo(taskDoneButton.snp.trailing).offset(14)
            $0.trailing.equalTo(isPriorityButton.snp.leading).offset(-5)
            $0.height.greaterThanOrEqualTo(45)
        }

        isPriorityButton.snp.makeConstraints {
            $0.size.equalTo(30)
            $0.trailing.equalToSuperview().inset(12)
            $0.top.equalToSuperview().inset(6)
        }

        taskDataTableView.snp.makeConstraints {
            $0.top.equalTo(topControlsContainerView.snp.bottom)
            $0.horizontalEdges.bottom.equalToSuperview()
        }
    }

    func setupBindingsToViewModel() {
        viewModel.taskTitle.bindAndUpdateValue { [unowned self] title in
            taskTitleTextView.text = title
        }

        viewModel.taskIsCompleted.bindAndUpdateValue { [unowned self] isCompleted in
            taskDoneButton.isOn = isCompleted
        }

        viewModel.taskIsPriority.bindAndUpdateValue { [unowned self] isPriority in
            isPriorityButton.isOn = isPriority
        }

        viewModel.bindingDelegate = self
    }

    // MARK: - Actions handlers

    @objc func didTapTaskDoneButton(sender: CheckboxButton) {
        viewModel.updateTaskField(isCompleted: !sender.isOn)
    }

    @objc func didTapTaskIsPriorityButton(sender: StarButton) {
        viewModel.updateTaskField(isPriority: !sender.isOn)
    }

    // MARK: - Helpers

    private func buildTableViewCellFor(_ cellViewModel: TaskDataCellViewModelType) -> UITableViewCell {
        let cell: UITableViewCell?

        switch cellViewModel {
        case _ as AddSubTaskCellViewModel:
            cell = taskDataTableView.dequeueReusableCell(withIdentifier: TaskDetailAddSubtaskCell.className)
            if let cell = cell as? TaskDetailAddSubtaskCell {
                cell.subtaskTextField.delegate = self
            }

        case let cellVM as AddToMyDayCellViewModel:
            cell = taskDataTableView.dequeueReusableCell(withIdentifier: TaskDetailAddToMyDayCell.className)
            if let cell = cell as? TaskDetailAddToMyDayCell {
                cell.isOn = cellVM.inMyDay
                cell.delegate = self
            }

        case let cellVM as ReminderDateCellViewModel:
            cell = taskDataTableView.dequeueReusableCell(withIdentifier: ReminderDateButtonCell.className)
            if let cell = cell as? ReminderDateButtonCell {
                cell.fillFrom(cellVM)
                cell.delegate = self
            }

        case let cellVM as DeadlineDateCellViewModel:
            cell = taskDataTableView.dequeueReusableCell(withIdentifier: DeadlineDateButtonCell.className)
            if let cell = cell as? DeadlineDateButtonCell {
                cell.fillFrom(cellVM)
                cell.delegate = self
            }

        case let cellVM as RepeatPeriodCellViewModel:
            cell = taskDataTableView.dequeueReusableCell(withIdentifier: RepeatPeriodButtonCell.className)
            if let cell = cell as? RepeatPeriodButtonCell {
                cell.fillFrom(cellVM)
                cell.delegate = self
            }

        case _ as AddFileCellVeiwModel:
            cell = taskDataTableView.dequeueReusableCell(withIdentifier: AddFileButtonCell.className)

        case let cellVM as FileCellViewModel:
            cell = taskDataTableView.dequeueReusableCell(withIdentifier: FileButtonCell.className)
            if let cell = cell as? FileButtonCell {
                cell.delegate = self
                cell.fillFrom(cellValue: cellVM)
            }

        case let cellVM as DescriptionCellViewModel:
            cell = taskDataTableView.dequeueReusableCell(withIdentifier: DescriptionButtonCell.className)
            if let cell = cell as? DescriptionButtonCell {
                cell.delegate = self
                cell.fillFrom(cellVM)
            }

        default :
            cell = taskDataTableView.dequeueReusableCell(withIdentifier: TaskDetailLabelsButtonCell.className)
            // TODO: залогировать
        }

        return cell ?? .init()
    }


}

// MARK: - UITableViewDataSource

extension TaskDetailView: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return viewModel.countTaskDataCellsValues
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cellVM = viewModel.getTaskDataCellViewModelFor(indexPath: indexPath)

        return buildTableViewCellFor(cellVM)
    }
}

// MARK: - UITableViewDelegate

extension TaskDetailView: UITableViewDelegate {

    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        let cellVM = viewModel.getTaskDataCellViewModelFor(indexPath: indexPath)

        switch cellVM {
        case _ as AddSubTaskCellViewModel:
            return TaskDetailAddSubtaskCell.rowHeight.cgFloat

        case _ as AddToMyDayCellViewModel:
            return TaskDetailAddToMyDayCell.rowHeight.cgFloat

        case _ as ReminderDateCellViewModel:
            return ReminderDateButtonCell.rowHeight.cgFloat

        case _ as DeadlineDateCellViewModel:
            return DeadlineDateButtonCell.rowHeight.cgFloat

        case _ as RepeatPeriodCellViewModel:
            return RepeatPeriodButtonCell.rowHeight.cgFloat

        case _ as AddFileCellVeiwModel:
            return AddFileButtonCell.rowHeight.cgFloat

        case _ as FileCellViewModel:
            return FileButtonCell.rowHeight.cgFloat

        case let cellVM as DescriptionCellViewModel:
            return cellVM.content == nil
            ? DescriptionButtonCell.emptyHeight.cgFloat
            : DescriptionButtonCell.maxHeight.cgFloat

        default :
            return TaskDetailBaseCell.rowHeight.cgFloat
        }
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let cell = tableView.cellForRow(at: indexPath)

        switch cell {
        case let addSubtaskButton as TaskDetailAddSubtaskCell :
            addSubtaskButton.subtaskTextField.becomeFirstResponder()

        case _ as TaskDetailAddToMyDayCell :
            viewModel.switchValueTaskFieldInMyDay()

        case _ as ReminderDateButtonCell :
            break
//            coordinator?.tapReminderDateCell()

        case _ as DeadlineDateButtonCell :
            break
//            coordinator?.tapDeadlineDateCell()

        case _ as RepeatPeriodButtonCell :
            break
//            coordinator?.tapRepeatPeriodCell()

        case _ as AddFileButtonCell :
            break
//            coordinator?.tapAddFileCell()

        case _ as FileButtonCell :
            print("💎 Открылся контроллер и показать содержимое файла")

        case _ as DescriptionButtonCell:
            break
//            coordinator?.tapDecriptionCell()

        default :
            break
        }

        tableView.deselectRow(at: indexPath, animated: false)
    }


    // MARK: swipers actions
    
    func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        let deleteAction = UIContextualAction(
            style: .destructive,
            title: "Удалить"
        ) { [weak self] _, _, completionHandler in
//            self?.startDeleteFileCoordinatorFor(indexPath)

            completionHandler(true)
        }
        let symbolConfig = UIImage.SymbolConfiguration(pointSize: 14, weight: .bold)
        deleteAction.image = UIImage(systemName: "trash", withConfiguration: symbolConfig)

        return UISwipeActionsConfiguration(actions: [deleteAction])
    }

    // MARK: "edit" / delete row

    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        if viewModel.isFileCellViewModel(byIndexPath: indexPath) {
            return true
        }

        return false
    }

    func tableView(_ tableView: UITableView, editingStyleForRowAt indexPath: IndexPath) -> UITableViewCell.EditingStyle {
        return .none
    }

    func tableView(_ tableView: UITableView, shouldIndentWhileEditingRowAt indexPath: IndexPath) -> Bool {
        return false
    }

}

// MARK: - UITextViewDelegate (taskTitle)

extension TaskDetailView: UITextViewDelegate {
    func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
        if (text == "\n") {
//            navigationController?.navigationBar.topItem?.setRightBarButton(nil, animated: true)
            textView.resignFirstResponder()

            return false
        } else {
            return true
        }
    }

    func textViewDidBeginEditing(_ textView: UITextView) {
//        showTaskTitleNavigationItemReady()
    }

    func textViewDidEndEditing(_ textView: UITextView) {
        viewModel.updateTaskField(title: textView.text)
    }

    // TODO: заменять перевод строки на пробел когда заканчивается редактирование названия
}


// MARK: - TaskDetailViewModelBindingDelegate

extension TaskDetailView: TaskDetailViewModelBindingDelegate {
    func addCell(toIndexPath indexPath: IndexPath, cellViewModel: TaskDataCellViewModelType) {
        taskDataTableView.insertRows(at: [indexPath], with: .fade)
    }

    func updateCell(withIndexPath indexPath: IndexPath, cellViewModel: TaskDataCellViewModelType) {
        let cell = taskDataTableView.cellForRow(at: indexPath)

        switch cellViewModel {
        case _ as AddSubTaskCellViewModel:
            break

        case let cellVM as AddToMyDayCellViewModel:
            guard let cell = cell as? TaskDetailAddToMyDayCell else { return }
            cell.fillFrom(cellVM)

        case let cellVM as ReminderDateCellViewModel:
            guard let cell = cell as? ReminderDateButtonCell else { return }
            cell.fillFrom(cellVM)

        case let cellVM as DeadlineDateCellViewModel:
            guard let cell = cell as? DeadlineDateButtonCell else { return }
            cell.fillFrom(cellVM)

        case let cellVM as RepeatPeriodCellViewModel:
            guard let cell = cell as? RepeatPeriodButtonCell else { return }
            cell.fillFrom(cellVM)

        case _ as AddFileCellVeiwModel:
            break

        case let cellVM as FileCellViewModel:
            guard let cell = cell as? FileButtonCell else { return }
            cell.fillFrom(cellValue: cellVM)

        case let cellVM as DescriptionCellViewModel:
            guard let cell = cell as? DescriptionButtonCell else { return }
            cell.fillFrom(cellVM)

        default :
            // TODO: залогировать
            break
        }
    }

    func removeCells(withIndexPaths indexPaths: [IndexPath]) {
        taskDataTableView.deleteRows(at: indexPaths, with: .fade)
    }
}


// MARK: - UITextFieldDelegate (subtasks cells)

extension TaskDetailView: UITextFieldDelegate {
    func textFieldDidBeginEditing(_ textField: UITextField) {
        // TODO: определять верный ли textField
//        showSubtaskAddNavigationItemReady()
//        textFieldEditing = textField
    }

    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        // TODO: определять верный ли textField
        if textFieldEditing === textField {
            textField.resignFirstResponder()
//            navigationItem.setRightBarButton(nil, animated: true)
            textFieldEditing = nil
        }

        return false
    }
}

// MARK: - cell delegates, child controllers delegates

/// Делегаты связанные с крестиками в ячейках данных задачи у полей:
/// - "Добавить в мой день" [x]
/// - "Дата напоминания" [x]
/// - "Дата выполнения" [x]
/// - "Период повтора" [x]
/// - "Прикрепленный файл" [х] - удаление
extension TaskDetailView: TaskDetailDataBaseCellDelegate {
    func taskDetailDataCellDidTapActionButton(cellIdentifier: String, cell: UITableViewCell) {
        switch cellIdentifier {
        case TaskDetailAddToMyDayCell.className:
            viewModel.updateTaskField(inMyDay: false)

        case ReminderDateButtonCell.className:
            viewModel.updateTaskField(reminderDateTime: nil)

        case DeadlineDateButtonCell.className:
            viewModel.updateTaskField(deadlineDate: nil)

        case RepeatPeriodButtonCell.className :
            viewModel.updateTaskField(repeatPeriod: nil)

        case FileButtonCell.className :
            let indexPath = taskDataTableView.indexPath(for: cell)
            guard let indexPath else { return }

//            startDeleteFileCoordinatorFor(indexPath)
            break

        default :
            break
        }

    }
}

// MARK: - DescriptionButtonCellDelegateProtocol
/// Делегат связанный с полем "Описание"

extension TaskDetailView: DescriptionButtonCellDelegateProtocol {
    func didTapTaskDescriptionOpenButton() {
//        coordinator?.taskDetailVCDidTapDecriptionCell()
    }
}
