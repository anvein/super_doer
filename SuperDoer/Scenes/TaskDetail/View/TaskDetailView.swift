import UIKit
import SnapKit
import RxSwift
import RxCocoa

final class TaskDetailView: UIView {
    private weak var viewModel: (TaskDetailViewModelInput & TaskDetailViewModelOutput)?

    private let disposeBag = DisposeBag()

    // MARK: - Subviews

    private var topControlsContainerView = UIView()

    private let isCompletedTaskCheckbox = CheckboxToggleView()
    private let titleTextView = UITextView()
    private let isPriorityToggle = StarToggleView()

    private let taskDataTableView = TaskDetailTableView()

    // MARK: - Init

    init(viewModel: TaskDetailViewModelInput & TaskDetailViewModelOutput) {
        super.init(frame: .zero)
        self.viewModel = viewModel
        setupView()
        setupHierarchyAndConstraints()
        setupBindings()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

}

private extension TaskDetailView {

    // MARK: - Setup

    func setupView() {
        backgroundColor = .Common.white

        isCompletedTaskCheckbox.visibleAreaInsets = 4
        isPriorityToggle.imageInsets = 4

        titleTextView.isScrollEnabled = false
        titleTextView.returnKeyType = .done

        titleTextView.backgroundColor = .Common.white
        titleTextView.textColor = .Text.black
        titleTextView.font = .systemFont(ofSize: 22, weight: .medium)

        titleTextView.delegate = self

        taskDataTableView.dataSource = self
        taskDataTableView.delegate = self
    }

    func setupHierarchyAndConstraints() {
        addSubviews(topControlsContainerView, taskDataTableView)
        topControlsContainerView.addSubviews(isCompletedTaskCheckbox, titleTextView, isPriorityToggle)

        topControlsContainerView.snp.makeConstraints {
            $0.top.equalTo(self.safeAreaLayoutGuide).offset(18)
            $0.horizontalEdges.equalToSuperview()
        }

        isCompletedTaskCheckbox.snp.makeConstraints {
            $0.size.equalTo(34)
            $0.top.equalToSuperview().inset(5)
            $0.leading.equalToSuperview().inset(15)
        }

        titleTextView.snp.makeConstraints {
            $0.verticalEdges.equalToSuperview()
            $0.leading.equalTo(isCompletedTaskCheckbox.snp.trailing).offset(10)
            $0.trailing.equalTo(isPriorityToggle.snp.leading).offset(-5)
            $0.height.greaterThanOrEqualTo(45)
        }

        isPriorityToggle.snp.makeConstraints {
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
        guard let viewModel else { return }

        // VM -> V
        viewModel.titleDriver
            .distinctUntilChanged()
            .drive(onNext: { [titleTextView] text in
                titleTextView.text = text
            })
            .disposed(by: disposeBag)

        viewModel.isCompletedDriver
            .distinctUntilChanged()
            .drive(onNext: { [isCompletedTaskCheckbox] newValue in
                isCompletedTaskCheckbox.value = newValue
            })
            .disposed(by: disposeBag)

        viewModel.isPriorityDriver
            .distinctUntilChanged()
            .drive { [isPriorityToggle] newValue in
                isPriorityToggle.value = newValue
            }
            .disposed(by: disposeBag)

        viewModel.fieldEditingStateDriver
            .distinctUntilChanged()
            .filter { $0 == nil }
            .drive(onNext: { [weak self] _ in
                self?.endEditing(true)
            })
            .disposed(by: disposeBag)

        viewModel.tableUpdateSignal
            .emit(onNext: { [weak self] event in
                self?.handleViewModelTableUpdate(event: event)
            })
            .disposed(by: disposeBag)

        // V -> VM
        titleTextView.rx.didBeginEditing
            .map { .didBeginTaskTitleEditing }
            .bind(to: viewModel.inputEvent)
            .disposed(by: disposeBag)

        titleTextView.rx.didEndEditing
            .withLatestFrom(titleTextView.rx.text)
            .map { .didEndTaskTitleEditing(newValue: $0) }
            .bind(to: viewModel.inputEvent)
            .disposed(by: disposeBag)

        isCompletedTaskCheckbox.valueChangedSignal
            .map { .didChangeIsCompleted(newValue: $0) }
            .emit(to: viewModel.inputEvent)
            .disposed(by: disposeBag)

        isPriorityToggle.valueChangedSignal
            .map { .didChangeIsPriority(newValue: $0) }
            .emit(to: viewModel.inputEvent)
            .disposed(by: disposeBag)
    }

    // MARK: - Actions / Events handlers

    func handleViewModelTableUpdate(event: TaskDetailTableViewModel.UpdateEvent) {
        switch event {
        case .addCell(let toIndexPath, _):
            taskDataTableView.insertRows(at: [toIndexPath], with: .fade)

        case .updateCell(let indexPath, let cellVM):
            updateTableViewCell(with: indexPath, cellVM: cellVM)

        case .removeCells(let indexPaths):
            taskDataTableView.deleteRows(at: indexPaths, with: .fade)

        case .refill:
            taskDataTableView.reloadData()
        }
    }

    // MARK: - Helpers

    func buildTableViewCellFor(_ cellViewModel: TaskDetailTableCellViewModelType) -> UITableViewCell {
        let cell: UITableViewCell?

        switch cellViewModel {
        case _ as CreateSubtaskCellViewModel:
            cell = taskDataTableView.dequeueReusableCell(withIdentifier: TaskDetailAddSubtaskCell.className)
            if let cell = cell as? TaskDetailAddSubtaskCell {
                cell.titleTextField.delegate = self
            }

        case let cellVM as AddToMyDayCellViewModel:
            cell = taskDataTableView.dequeueReusableCell(withIdentifier: TaskDetailAddToMyDayCell.className)
            if let cell = cell as? TaskDetailAddToMyDayCell {
                cell.isOn = cellVM.inMyDay
                cell.delegate = self
            }

        case let cellVM as TaskDetailReminderDateCellViewModel:
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

        case let cellVM as TaskDetailRepeatPeriodCellViewModel:
            cell = taskDataTableView.dequeueReusableCell(withIdentifier: TaskDetailRepeatPeriodCell.className)
            if let cell = cell as? TaskDetailRepeatPeriodCell {
                cell.fillFrom(cellVM)
                cell.delegate = self
            }

        case _ as ImportFileCellViewModel:
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

        default:
            cell = taskDataTableView.dequeueReusableCell(withIdentifier: TaskDetailLabelsButtonCell.className)
            // TODO: залогировать
        }

        return cell ?? .init()
    }

    func updateTableViewCell(with indexPath: IndexPath, cellVM: TaskDetailTableCellViewModelType) {
        let cell = taskDataTableView.cellForRow(at: indexPath)

        switch cellVM {
        case _ as CreateSubtaskCellViewModel:
            break

        case let cellVM as AddToMyDayCellViewModel:
            guard let cell = cell as? TaskDetailAddToMyDayCell else { return }
            cell.fillFrom(cellVM)

        case let cellVM as TaskDetailReminderDateCellViewModel:
            guard let cell = cell as? TaskDetailReminderDateCell else { return }
            cell.fillFrom(cellVM)

        case let cellVM as DeadlineDateCellViewModel:
            guard let cell = cell as? TaskDetailDeadlineDateCell else { return }
            cell.fillFrom(cellVM)

        case let cellVM as TaskDetailRepeatPeriodCellViewModel:
            guard let cell = cell as? TaskDetailRepeatPeriodCell else { return }
            cell.fillFrom(cellVM)

        case _ as ImportFileCellViewModel:
            break

        case let cellVM as FileCellViewModel:
            guard let cell = cell as? TaskDetailFileCell else { return }
            cell.fillFrom(cellValue: cellVM)

        case let cellVM as DescriptionCellViewModel:
            guard let cell = cell as? TaskDetailDescriptionCell else { return }
            cell.fillFrom(cellVM)

        default:
            break
        }
    }

}

// MARK: - UITableViewDataSource

extension TaskDetailView: UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        viewModel?.countSections ?? 0
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        viewModel?.getCountRowsInSection(section) ?? 0
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let viewModel, let cellVM = viewModel.getTableCellViewModel(for: indexPath) else {
            return .init()
        }

        return buildTableViewCellFor(cellVM)
    }
}

// MARK: - UITableViewDelegate

extension TaskDetailView: UITableViewDelegate {

    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        let cellVM = viewModel?.getTableCellViewModel(for: indexPath)

        switch cellVM {
        case _ as CreateSubtaskCellViewModel:
            return TaskDetailAddSubtaskCell.rowHeight.cgFloat

        case _ as AddToMyDayCellViewModel:
            return TaskDetailAddToMyDayCell.rowHeight.cgFloat

        case _ as TaskDetailReminderDateCellViewModel:
            return TaskDetailReminderDateCell.rowHeight.cgFloat

        case _ as DeadlineDateCellViewModel:
            return TaskDetailDeadlineDateCell.rowHeight.cgFloat

        case _ as TaskDetailRepeatPeriodCellViewModel:
            return TaskDetailRepeatPeriodCell.rowHeight.cgFloat

        case _ as ImportFileCellViewModel:
            return TaskDetailAddFileCell.rowHeight.cgFloat

        case _ as FileCellViewModel:
            return TaskDetailFileCell.rowHeight.cgFloat

        case let cellVM as DescriptionCellViewModel:
            return cellVM.text == nil
            ? TaskDetailDescriptionCell.emptyHeight.cgFloat
            : TaskDetailDescriptionCell.maxHeight.cgFloat

        default:
            return TaskDetailBaseCell.rowHeight.cgFloat
        }
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let cell = tableView.cellForRow(at: indexPath)

        switch cell {
        case let addSubtaskButton as TaskDetailAddSubtaskCell:
            addSubtaskButton.titleTextField.becomeFirstResponder()

        case _ as TaskDetailAddToMyDayCell:
            viewModel?.inputEvent.accept(.didToggleValueInMyDay)

        case _ as TaskDetailReminderDateCell:
            viewModel?.inputEvent.accept(.didTapOpenReminderDateSetter)

        case _ as TaskDetailDeadlineDateCell:
            viewModel?.inputEvent.accept(.didTapOpenDeadlineDateSetter)

        case _ as TaskDetailRepeatPeriodCell:
            viewModel?.inputEvent.accept(.didTapOpenRepeatPeriodSetter)

        case _ as TaskDetailAddFileCell:
            viewModel?.inputEvent.accept(.didTapAddFile)

        case _ as TaskDetailFileCell:
            print("💎 Открылся контроллер и показать содержимое файла")

        case _ as TaskDetailDescriptionCell:
            viewModel?.inputEvent.accept(.didTapOpenDescriptionEditor)

        default:
            break
        }

        tableView.deselectRow(at: indexPath, animated: false)
    }

    // MARK: swipes actions

    func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        let deleteAction = UIContextualAction(
            style: .destructive,
            title: "Удалить"
        ) { [weak self] _, _, completionHandler in
            self?.viewModel?.inputEvent.accept(
                .didTapFileDelete(indexPath: indexPath)
            )
            completionHandler(true)
        }

        let symbolConfig = UIImage.SymbolConfiguration(pointSize: 14, weight: .bold)
        deleteAction.image = UIImage(systemName: "trash", withConfiguration: symbolConfig)

        return UISwipeActionsConfiguration(actions: [deleteAction])
    }

    // MARK: "edit" / delete row

    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        if let viewModel, viewModel.canDeleteCell(with: indexPath) {
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
extension TaskDetailView: TaskDetailDataCellDelegate {
    func taskDetailDataCellDidTapActionButton(cellIdentifier: String, cell: UITableViewCell) {
        switch cellIdentifier {
        case TaskDetailAddToMyDayCell.className:
            viewModel?.inputEvent.accept(.didTapResetValueInMyDay)

        case TaskDetailReminderDateCell.className:
            viewModel?.inputEvent.accept(.didTapResetValueReminderDate)

        case TaskDetailDeadlineDateCell.className:
            viewModel?.inputEvent.accept(.didTapResetValueDeadlineDate)

        case TaskDetailRepeatPeriodCell.className:
            viewModel?.inputEvent.accept(.didTapResetValueRepeatPeriod)

        case TaskDetailFileCell.className:
            guard let indexPath = taskDataTableView.indexPath(for: cell) else { return }
            viewModel?.inputEvent.accept(.didTapFileDelete(indexPath: indexPath))

        default:
            break
        }

    }
}

// MARK: - DescriptionButtonCellDelegateProtocol
/// Делегат связанный с полем "Описание"

extension TaskDetailView: DescriptionButtonCellDelegateProtocol {
    func didTapTaskDescriptionOpenButton() {
        viewModel?.inputEvent.accept(.didTapOpenDescriptionEditor)
    }
}
