
import UIKit
import SnapKit

final class TaskDetailView: UIView {

    private let viewModel: TaskDetailViewModel

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

    // MARK: - State

    /// Редактируемое в данный момент поле TextField
    private var textFieldEditing: UITextField?

    // MARK: - Init

    init(viewModel: TaskDetailViewModel) {
        self.viewModel = viewModel

        super.init(frame: .zero)
        setupSubvies()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    

}

private extension TaskDetailView {

    // MARK: - Setup

    func setupSubvies() {
        view.addSubviews(taskDoneButton, taskTitleTextView, isPriorityButton, taskDataTableView)

        // view of controller
        view.backgroundColor = .Common.white
    }

    // MARK: - Actions handlers

    @objc func didTapTaskDoneButton(sender: CheckboxButton) {
        viewModel.updateTaskField(isCompleted: !sender.isOn)
    }

    @objc func didTapTaskIsPriorityButton(sender: StarButton) {
        viewModel.updateTaskField(isPriority: !sender.isOn)
    }


}
