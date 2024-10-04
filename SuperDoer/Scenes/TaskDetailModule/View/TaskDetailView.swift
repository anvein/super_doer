
import UIKit
import SnapKit
import RxSwift
import RxCocoa

final class TaskDetailView: UIView {

    private let viewModel: TaskDetailViewModel

    private let disposeBag = DisposeBag()

    // MARK: - Subviews

    private var topControlsContainerView = UIView()

    private let isCompletedTaskButton = CheckboxButton()
    private let titleTextView = UITextView()
    private let isPriorityButton = StarButton()

    private let taskDataTableView = TaskDetailTableView()

    // MARK: - Bindings

    let userAnswerRelay = PublishRelay<UserAnswer>()

    /// Редактируемое в данный момент поле TextField
//    var textFieldEditing: UITextField?

    // MARK: - Init

    init(viewModel: TaskDetailViewModel) {
        self.viewModel = viewModel

        super.init(frame: .zero)
        setup()
        setupSubviews()
        setupLayoutSubviews()
        setupBindings()
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

    func setupSubviews() {
        titleTextView.isScrollEnabled = false
        titleTextView.returnKeyType = .done

        titleTextView.backgroundColor = .Common.white
        titleTextView.textColor = .Text.black
        titleTextView.font = .systemFont(ofSize: 22, weight: .medium)

        titleTextView.delegate = self

        taskDataTableView.dataSource = self
        taskDataTableView.delegate = self
    }

    func setupLayoutSubviews() {
        addSubviews(topControlsContainerView, taskDataTableView)
        topControlsContainerView.addSubviews(isCompletedTaskButton, titleTextView, isPriorityButton)

        topControlsContainerView.snp.makeConstraints {
            $0.top.equalTo(self.safeAreaLayoutGuide).offset(18)
            $0.horizontalEdges.equalToSuperview()
        }

        isCompletedTaskButton.snp.makeConstraints {
            $0.size.equalTo(26)
            $0.top.equalToSuperview().inset(9)
            $0.leading.equalToSuperview().inset(19)
        }

        titleTextView.snp.makeConstraints {
            $0.verticalEdges.equalToSuperview()
            $0.leading.equalTo(isCompletedTaskButton.snp.trailing).offset(14)
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

    func setupBindings() {
        // VM -> V
        viewModel.titleDriver
            .drive(onNext: { [titleTextView] text in
                guard titleTextView.text != text else { return }
                titleTextView.text = text
            })
            .disposed(by: disposeBag)

        viewModel.isCompletedDriver
            .drive(onNext: { [isCompletedTaskButton] isCompleted in
                guard isCompleted != isCompletedTaskButton.isOn else { return }
                isCompletedTaskButton.isOn = isCompleted
            })
            .disposed(by: disposeBag)

        viewModel.isPriorityDriver
            .drive { [isPriorityButton] isPriority in
                guard isPriority != isPriorityButton.isOn else { return }
                isPriorityButton.isOn = isPriority
            }
            .disposed(by: disposeBag)

        viewModel.fieldEditingStateDriver
            .filter { $0 == nil }
            .emit(onNext: { [weak self] state in
                self?.endEditing(true)
            })
            .disposed(by: disposeBag)

        // V -> VM
        titleTextView.rx.didBeginEditing
            .subscribe(onNext: { [viewModel] in
                viewModel.setEditingState(.taskTitleEditing)
            })
            .disposed(by: disposeBag)

        titleTextView.rx.didEndEditing
            .withLatestFrom(titleTextView.rx.text.orEmpty)
            .subscribe(onNext: { [viewModel] text in
                viewModel.updateTaskField(title: text)
                viewModel.setEditingState(nil)
            })
            .disposed(by: disposeBag)

        isCompletedTaskButton.rx.tap
            .subscribe(onNext: { [viewModel, isCompletedTaskButton] in
                viewModel.updateTaskField(isCompleted: !isCompletedTaskButton.isOn)
            })
            .disposed(by: disposeBag)

        isPriorityButton.rx.tap
            .subscribe(onNext: { [viewModel, isPriorityButton] in
                viewModel.updateTaskField(isPriority: !isPriorityButton.isOn)
            })
            .disposed(by: disposeBag)


        viewModel.bindingDelegate = self
    }

    // MARK: - Helpers

    private func buildTableViewCellFor(_ cellViewModel: TaskDetailDataCellViewModelType) -> UITableViewCell {
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
            cell = taskDataTableView.dequeueReusableCell(withIdentifier: TaskDetailReminderDateCell.className)
            if let cell = cell as? TaskDetailReminderDateCell {
                cell.fillFrom(cellVM)
                cell.delegate = self
            }

        case let cellVM as DeadlineDateCellViewModel:
            cell = taskDataTableView.dequeueReusableCell(withIdentifier: TaskDetailDeadlineDateCell.className)
            if let cell = cell as? TaskDetailDeadlineDateCell {
                cell.fillFrom(cellVM)
                cell.delegate = self
            }

        case let cellVM as RepeatPeriodCellViewModel:
            cell = taskDataTableView.dequeueReusableCell(withIdentifier: TaskDetailRepeatPeriodCell.className)
            if let cell = cell as? TaskDetailRepeatPeriodCell {
                cell.fillFrom(cellVM)
                cell.delegate = self
            }

        case _ as AddFileCellVeiwModel:
            cell = taskDataTableView.dequeueReusableCell(withIdentifier: TaskDetailAddFileCell.className)

        case let cellVM as FileCellViewModel:
            cell = taskDataTableView.dequeueReusableCell(withIdentifier: TaskDetailFileCell.className)
            if let cell = cell as? TaskDetailFileCell {
                cell.delegate = self
                cell.fillFrom(cellValue: cellVM)
            }

        case let cellVM as DescriptionCellViewModel:
            cell = taskDataTableView.dequeueReusableCell(withIdentifier: TaskDetailDescriptionCell.className)
            if let cell = cell as? TaskDetailDescriptionCell {
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
    func numberOfSections(in tableView: UITableView) -> Int {
        return viewModel.countSections
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return viewModel.getCountRowsInSection(section)
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cellVM = viewModel.getTaskDataCellViewModelFor(indexPath: indexPath) else { return .init() }

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
            return TaskDetailReminderDateCell.rowHeight.cgFloat

        case _ as DeadlineDateCellViewModel:
            return TaskDetailDeadlineDateCell.rowHeight.cgFloat

        case _ as RepeatPeriodCellViewModel:
            return TaskDetailRepeatPeriodCell.rowHeight.cgFloat

        case _ as AddFileCellVeiwModel:
            return TaskDetailAddFileCell.rowHeight.cgFloat

        case _ as FileCellViewModel:
            return TaskDetailFileCell.rowHeight.cgFloat

        case let cellVM as DescriptionCellViewModel:
            return cellVM.content == nil
            ? TaskDetailDescriptionCell.emptyHeight.cgFloat
            : TaskDetailDescriptionCell.maxHeight.cgFloat

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

        case _ as TaskDetailReminderDateCell :
            userAnswerRelay.accept(.reminderDateSetterOpenDidTap)

        case _ as TaskDetailDeadlineDateCell :
            userAnswerRelay.accept(.deadlineDateSetterOpenDidTap)

        case _ as TaskDetailRepeatPeriodCell :
            userAnswerRelay.accept(.repeatPeriodSetterOpenDidTap)

        case _ as TaskDetailAddFileCell :
            userAnswerRelay.accept(.fileAddDidTap)

        case _ as TaskDetailFileCell :
            print("💎 Открылся контроллер и показать содержимое файла")

        case _ as TaskDetailDescriptionCell:
            userAnswerRelay.accept(.descriptionEditorOpenDidTap)

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
            self?.userAnswerRelay.accept(.fileDeleteDidTap(indexPath: indexPath))
            completionHandler(true)
        }
        
        let symbolConfig = UIImage.SymbolConfiguration(pointSize: 14, weight: .bold)
        deleteAction.image = UIImage(systemName: "trash", withConfiguration: symbolConfig)

        return UISwipeActionsConfiguration(actions: [deleteAction])
    }

    // MARK: "edit" / delete row

    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        if viewModel.isFileCellViewModel(with: indexPath) {
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
        if text == "\n" {
            textView.resignFirstResponder()
            return false
        } else {
            return true
        }
    }

    // TODO: заменять перевод строки на пробел когда заканчивается редактирование названия
}

// MARK: - TaskDetailViewModelBindingDelegate

extension TaskDetailView: TaskDetailViewModelBindingDelegate {
    func addCell(toIndexPath indexPath: IndexPath, cellViewModel: TaskDetailDataCellViewModelType) {
        taskDataTableView.insertRows(at: [indexPath], with: .fade)
    }

    func updateCell(withIndexPath indexPath: IndexPath, cellViewModel: TaskDetailDataCellViewModelType) {
        let cell = taskDataTableView.cellForRow(at: indexPath)

        switch cellViewModel {
        case _ as AddSubTaskCellViewModel:
            break

        case let cellVM as AddToMyDayCellViewModel:
            guard let cell = cell as? TaskDetailAddToMyDayCell else { return }
            cell.fillFrom(cellVM)

        case let cellVM as ReminderDateCellViewModel:
            guard let cell = cell as? TaskDetailReminderDateCell else { return }
            cell.fillFrom(cellVM)

        case let cellVM as DeadlineDateCellViewModel:
            guard let cell = cell as? TaskDetailDeadlineDateCell else { return }
            cell.fillFrom(cellVM)

        case let cellVM as RepeatPeriodCellViewModel:
            guard let cell = cell as? TaskDetailRepeatPeriodCell else { return }
            cell.fillFrom(cellVM)

        case _ as AddFileCellVeiwModel:
            break

        case let cellVM as FileCellViewModel:
            guard let cell = cell as? TaskDetailFileCell else { return }
            cell.fillFrom(cellValue: cellVM)

        case let cellVM as DescriptionCellViewModel:
            guard let cell = cell as? TaskDetailDescriptionCell else { return }
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

//    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
//        // TODO: определять верный ли textField
////        if textFieldEditing === textField {
////            textField.resignFirstResponder()
//////            navigationItem.setRightBarButton(nil, animated: true)
////            textFieldEditing = nil
////        }
//
//        return false
//    }
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

        case TaskDetailReminderDateCell.className:
            viewModel.updateTaskField(reminderDateTime: nil)

        case TaskDetailDeadlineDateCell.className:
            viewModel.updateTaskField(deadlineDate: nil)

        case TaskDetailRepeatPeriodCell.className :
            viewModel.updateTaskField(repeatPeriod: nil)

        case TaskDetailFileCell.className :
            guard let indexPath = taskDataTableView.indexPath(for: cell) else { return }
            userAnswerRelay.accept(.fileDeleteDidTap(indexPath: indexPath))

        default :
            break
        }

    }
}

// MARK: - DescriptionButtonCellDelegateProtocol
/// Делегат связанный с полем "Описание"

extension TaskDetailView: DescriptionButtonCellDelegateProtocol {
    func didTapTaskDescriptionOpenButton() {
        userAnswerRelay.accept(.descriptionEditorOpenDidTap)
    }
}

extension TaskDetailView {
    enum UserAnswer {
        case reminderDateSetterOpenDidTap
        case deadlineDateSetterOpenDidTap
        case repeatPeriodSetterOpenDidTap
        case fileAddDidTap
        case fileDeleteDidTap(indexPath: IndexPath)
        case descriptionEditorOpenDidTap
    }
}
