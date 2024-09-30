
import UIKit
import SnapKit

class TaskDetailViewController: UIViewController {
    private var viewModel: TaskDetailViewModel
    private weak var coordinator: TaskDetailViewControllerCoordinator?

    // MARK: - Subviews

    private lazy var taskDoneButton: CheckboxButton = {
        $0.addTarget(self, action: #selector(didTapTaskDoneButton(sender:)), for: .touchUpInside)
        return $0
    }(CheckboxButton())

    private lazy var taskTitleTextView: UITextView = {
        $0.isScrollEnabled = false
        $0.returnKeyType = .done

        $0.backgroundColor = .Common.white
        $0.textColor = .Text.black
        $0.font = UIFont.systemFont(ofSize: 22, weight: .medium)
        return $0
    }(UITextView())
    
    private lazy var isPriorityButton: StarButton = {
        $0.addTarget(self, action: #selector(didTapTaskIsPriorityButton(sender:)), for: .touchUpInside)
        return $0
    }(StarButton())

    private lazy var taskDataTableView: TaskDetailTableView = .init()

    /// Редактируемое в данный момент поле TextField
    private var textFieldEditing: UITextField?
    
    // MARK: - Init

    init(
        coordinator: TaskDetailViewControllerCoordinator,
        viewModel: TaskDetailViewModel
    ) {
        self.coordinator = coordinator
        self.viewModel = viewModel
        
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
    // MARK: - Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupView()
        setupConstraints()
        setupBindings()

        PIXEL_PERFECT_screen.createAndSetupInstance(
            baseView: self.view,
            imageName: "PIXEL_PERFECT_detail1",
            controlsBottomSideOffset: 0,
            imageScaleFactor: 3
        )
    }

    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        
        if isMovingFromParent {
            coordinator?.closeTaskDetail()
        }
    }
    
    
    // MARK: - Actions handlers

    @objc func didTapTaskDoneButton(sender: CheckboxButton) {
        viewModel.updateTaskField(isCompleted: !sender.isOn)
    }

    @objc func didTapTaskIsPriorityButton(sender: StarButton) {
        viewModel.updateTaskField(isPriority: !sender.isOn)
    }

    @objc func showTaskTitleNavigationItemReady() {
        let rightBarButonItem = UIBarButtonItem(
            title: "Готово",
            style: .done,
            target: self,
            action: #selector(pressedTaskTitleNavigationItemReady)
        )
        
        navigationController?.navigationBar.topItem?.setRightBarButton(rightBarButonItem, animated: true)
    }
    
    @objc func pressedTaskTitleNavigationItemReady() {
        navigationItem.setRightBarButton(nil, animated: true)
        taskTitleTextView.resignFirstResponder()
    }
    
    @objc func showSubtaskAddNavigationItemReady() {
        let rightBarButonItem = UIBarButtonItem(
            title: "Готово",
            style: .done,
            target: self,
            action: #selector(pressedSubtaskAddNavigationItemReady)
        )
        
        navigationItem.setRightBarButton(rightBarButonItem, animated: true)
    }
    
    @objc func pressedSubtaskAddNavigationItemReady() {
        // TODO: переделать на endEdit
        textFieldEditing?.resignFirstResponder()
        navigationItem.setRightBarButton(nil, animated: true)
    }
    
    
    // MARK: coordinator methods
    private func startDeleteFileCoordinatorFor(_ fileCellIndexPath: IndexPath) {
        let fileVM = viewModel.getFileDeletableViewModelFor(fileCellIndexPath)
        guard let fileVM else { return }
        
        coordinator?.startDeleteProcessFile(viewModel: fileVM)
    }
    
    
    // MARK: build / factory methods
    private func buildTableViewCellFor(_ cellViewModel: TaskDataCellViewModelType) -> UITableViewCell {
        let cell: UITableViewCell
        
        switch cellViewModel {
        case _ as AddSubTaskCellViewModel:
            cell = taskDataTableView.dequeueReusableCell(withIdentifier: AddSubtaskButtonCell.identifier)!
            if let cell = cell as? AddSubtaskButtonCell {
                cell.subtaskTextField.delegate = self
            }
            
        case let cellVM as AddToMyDayCellViewModel:
            cell = taskDataTableView.dequeueReusableCell(withIdentifier: AddToMyDayButtonCell.identifier)!
            if let cell = cell as? AddToMyDayButtonCell {
                cell.isOn = cellVM.inMyDay
                cell.delegate = self
            }
        
        case let cellVM as ReminderDateCellViewModel:
            cell = taskDataTableView.dequeueReusableCell(withIdentifier: ReminderDateButtonCell.identifier)!
            if let cell = cell as? ReminderDateButtonCell {
                cell.fillFrom(cellVM)
                cell.delegate = self
            }
            
        case let cellVM as DeadlineDateCellViewModel:
            cell = taskDataTableView.dequeueReusableCell(withIdentifier: DeadlineDateButtonCell.identifier)!
            if let cell = cell as? DeadlineDateButtonCell {
                cell.fillFrom(cellVM)
                cell.delegate = self
            }
            
        case let cellVM as RepeatPeriodCellViewModel:
            cell = taskDataTableView.dequeueReusableCell(withIdentifier: RepeatPeriodButtonCell.identifier)!
            if let cell = cell as? RepeatPeriodButtonCell {
                cell.fillFrom(cellVM)
                cell.delegate = self
            }
            
        case _ as AddFileCellVeiwModel:
            cell = taskDataTableView.dequeueReusableCell(withIdentifier: AddFileButtonCell.identifier)!
        
        case let cellVM as FileCellViewModel:
            cell = taskDataTableView.dequeueReusableCell(withIdentifier: FileButtonCell.identifier)!
            if let cell = cell as? FileButtonCell {
                cell.delegate = self
                cell.fillFrom(cellValue: cellVM)
            }
            
        case let cellVM as DescriptionCellViewModel:
            cell = taskDataTableView.dequeueReusableCell(withIdentifier: DescriptionButtonCell.identifier)!
            if let cell = cell as? DescriptionButtonCell {
                cell.delegate = self
                cell.fillFrom(cellVM)
            }
            
        default :
            cell = taskDataTableView.dequeueReusableCell(withIdentifier: TaskDetailLabelsButtonCell.identifier)!
            // TODO: залогировать
        }
        
        return cell
    }
    
}

private extension TaskDetailViewController {

    // MARK: - Setup

    func setupConstraints() {
        taskDoneButton.snp.makeConstraints {
            $0.size.equalTo(26)
            $0.top.equalTo(taskTitleTextView.snp.top).offset(9)
            $0.leading.equalToSuperview().inset(19)
        }

        taskTitleTextView.snp.makeConstraints {
            $0.top.equalTo(view.safeAreaLayoutGuide).offset(18)
            $0.leading.equalTo(taskDoneButton.snp.trailing).offset(14)
            $0.trailing.equalTo(isPriorityButton.snp.leading).offset(-5)
            $0.height.greaterThanOrEqualTo(45)
        }

        isPriorityButton.snp.makeConstraints {
            $0.size.equalTo(30)
            $0.centerX.equalTo(view.snp.trailing).offset(-27)
            $0.centerY.equalTo(taskTitleTextView.snp.top).offset(21)
        }

        taskDataTableView.snp.makeConstraints {
            $0.top.equalTo(taskTitleTextView.snp.bottom)
            $0.horizontalEdges.bottom.equalToSuperview()
        }
    }

    func setupView() {
        view.addSubviews(taskDoneButton, taskTitleTextView, isPriorityButton, taskDataTableView)

        // view of controller
        view.backgroundColor = .Common.white
        
        // navigationItem
        navigationItem.largeTitleDisplayMode = .never
        navigationController?.navigationBar.tintColor = .Text.blue
        
        // taskTitleTextView, taskDoneButton, isPriorityButton
        taskTitleTextView.delegate = self
        
        // taskDataTableView
        taskDataTableView.dataSource = self
        taskDataTableView.delegate = self
    }
    
    func setupBindings() {
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
}


// MARK: - UITableViewDelegate, UITableViewDataSource

extension TaskDetailViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return viewModel.countTaskDataCellsValues
    }
    
    
    // MARK: cell appearance
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cellVM = viewModel.getTaskDataCellViewModelFor(indexPath: indexPath)
        
        return buildTableViewCellFor(cellVM)
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        let cellVM = viewModel.getTaskDataCellViewModelFor(indexPath: indexPath)
       
        switch cellVM {
        case _ as AddSubTaskCellViewModel:
            return AddSubtaskButtonCell.rowHeight.cgFloat

        case _ as AddToMyDayCellViewModel:
            return AddToMyDayButtonCell.rowHeight.cgFloat
        
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
            return TaskDetailBaseButtonCell.rowHeight.cgFloat
        }
    }
    
    
    // MARK: select row
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let cell = tableView.cellForRow(at: indexPath)
        
        switch cell {
        case let addSubtaskButton as AddSubtaskButtonCell :
            addSubtaskButton.subtaskTextField.becomeFirstResponder()
        
        case _ as AddToMyDayButtonCell :
            viewModel.switchValueTaskFieldInMyDay()
            
        case _ as ReminderDateButtonCell :
            coordinator?.tapReminderDateCell()
            
        case _ as DeadlineDateButtonCell :
            coordinator?.tapDeadlineDateCell()
            
        case _ as RepeatPeriodButtonCell :
            coordinator?.tapRepeatPeriodCell()
            
        case _ as AddFileButtonCell :
            coordinator?.tapAddFileCell()
            
        case _ as FileButtonCell :
            print("💎 Открылся контроллер и показать содержимое файла")
            
        case _ as DescriptionButtonCell:
            coordinator?.tapDecriptionCell()
            
        default :
            break
        }
        
        tableView.deselectRow(at: indexPath, animated: false)
    }
    
    
    // MARK: swipes for row
    func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        let deleteAction = UIContextualAction(
            style: .destructive,
            title: "Удалить"
        ) { [weak self] _, _, completionHandler in
            self?.startDeleteFileCoordinatorFor(indexPath)
            
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


// MARK: - task title TextView delegate
extension TaskDetailViewController: UITextViewDelegate {
    func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
        if (text == "\n") {
            navigationController?.navigationBar.topItem?.setRightBarButton(nil, animated: true)
            textView.resignFirstResponder()
            
            return false
        } else {
            return true
        }
    }
    
    func textViewDidBeginEditing(_ textView: UITextView) {
        showTaskTitleNavigationItemReady()
    }
    
    func textViewDidEndEditing(_ textView: UITextView) {
        viewModel.updateTaskField(title: textView.text)
    }

    // TODO: заменять перевод строки на пробел когда заканчивается редактирование названия
}


// MARK: - subtask TextField delegate
extension TaskDetailViewController: UITextFieldDelegate {
    func textFieldDidBeginEditing(_ textField: UITextField) {
        // TODO: определять верный ли textField
        showSubtaskAddNavigationItemReady()
        textFieldEditing = textField
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        // TODO: определять верный ли textField
        if textFieldEditing === textField {
            textField.resignFirstResponder()
            navigationItem.setRightBarButton(nil, animated: true)
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
extension TaskDetailViewController: TaskDetailBaseButtonCellDelegate {
    func didTapTaskDetailCellActionButton(cellIdentifier: String, cell: UITableViewCell) {
        switch cellIdentifier {
        case AddToMyDayButtonCell.identifier:
            viewModel.updateTaskField(inMyDay: false)
            
        case ReminderDateButtonCell.identifier:
            viewModel.updateTaskField(reminderDateTime: nil)
            
        case DeadlineDateButtonCell.identifier:
            viewModel.updateTaskField(deadlineDate: nil)
            
        case RepeatPeriodButtonCell.identifier :
            viewModel.updateTaskField(repeatPeriod: nil)
    
        case FileButtonCell.identifier :
            let indexPath = taskDataTableView.indexPath(for: cell)
            guard let indexPath else { return }
            
            startDeleteFileCoordinatorFor(indexPath)
            break
            
        default :
            break
        }
        
    }
}

/// Делегаты связанные с полем "Описание"
extension TaskDetailViewController: DescriptionButtonCellDelegateProtocol {
    func didTapTaskDescriptionOpenButton() {
        coordinator?.tapDecriptionCell()
    }
}


// MARK: - binding with ViewModel delegate
extension TaskDetailViewController: TaskDetailViewModelBindingDelegate {
    func addCell(toIndexPath indexPath: IndexPath, cellViewModel: TaskDataCellViewModelType) {
        taskDataTableView.insertRows(at: [indexPath], with: .fade)
    }
    
    func updateCell(withIndexPath indexPath: IndexPath, cellViewModel: TaskDataCellViewModelType) {
        let cell = taskDataTableView.cellForRow(at: indexPath)
        
        switch cellViewModel {
        case _ as AddSubTaskCellViewModel:
            break
            
        case let cellVM as AddToMyDayCellViewModel:
            guard let cell = cell as? AddToMyDayButtonCell else { return }
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


// MARK: - coordinator protocol for TaskDetailViewController
protocol TaskDetailViewControllerCoordinator: AnyObject {
    /// Тап по ячейке с датой напоминания по задаче
    func tapReminderDateCell()
    
    /// Тап по ячейке с датой дедлайна задачи
    func tapDeadlineDateCell()
    
    /// Тап по ячейке с периодом повтора задачи
    func tapRepeatPeriodCell()
    
    // Тап по ячейке с описанием задачи
    func tapDecriptionCell()
    
    // Тап по ячейке "добавления файла"
    func tapAddFileCell()
    
    /// Пользователь начал "удалять задачу"
    func startDeleteProcessFile(viewModel: TaskFileDeletableViewModel)
    
    /// Задача закрыта (ушли с экрана просмотра / редактирования задачи)
    func closeTaskDetail()
    
}
