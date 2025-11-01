import Foundation
import RxRelay
import RxCocoa

class TaskDetailTableViewModel {

    enum UpdateEvent {
        case refill
        case addCell(to: IndexPath, cellVM: TaskDetailTableCellViewModelType)
        case updateCell(with: IndexPath, cellVM: TaskDetailTableCellViewModelType)
        case removeCells(with: [IndexPath])
        // move cell
    }

    enum Section: Int {
        case subtasks = 0
        case fields = 1
        case files = 2
        case description = 3

        static var sectionsCount: Int = 4
    }
    
    private var viewModels: [[TaskDetailTableCellViewModelType]] = Array(
        repeating: [],
        count: Section.sectionsCount
    )

    private let updateEventRelay = PublishRelay<TaskDetailTableViewModel.UpdateEvent>()
    var updateEvent: Signal<TaskDetailTableViewModel.UpdateEvent> {
        updateEventRelay.asSignal()
    }

    // MARK: - Output

    var countSections: Int { viewModels.count }

    func getCountRowsInSection(_ section: Int) -> Int {
        return viewModels[safe: section]?.count ?? 0
    }

    func getCellVM(for indexPath: IndexPath) -> TaskDetailTableCellViewModelType? {
        return viewModels[safe: indexPath.section]?[safe: indexPath.row]
    }

    // MARK: - Update View Model

    func refill(from task: CDTask) {
        viewModels = Array(repeating: [], count: Section.sectionsCount)

        addCreateSubtaskCellVM(withNotify: false)

        addInToMyDayCellVM(task.inMyDay, withNotify: false)

        addReminderDateCellVM(task.reminderDateTime, withNotify: false)
        addDeadlineDateCellVM(task.deadlineDate, withNotify: false)
        addRepeatPeriodCellVM(task.repeatPeriod, withNotify: false)

        addImportFileCellVM(withNotify: false)

        for file in task.files ?? []  {
            guard let file = file as? TaskFile else { continue }

            addFileCellVM(file, withNotify: false)
        }

        addDescriptionCellVM(
            text: task.descriptionTextAttributed,
            dateUpdatedAt: task.descriptionUpdatedAt,
            withNotify: false
        )

        updateEventRelay.accept(.refill)
    }

    @discardableResult
    func updateAddToMyDay(_ value: Bool) -> IndexPath? {
        updateUniqueCellVM(section: .fields) { (cellVM: AddToMyDayCellViewModel) -> AddToMyDayCellViewModel in
            var updatedCellVM = cellVM
            updatedCellVM.inMyDay = value
            return updatedCellVM
        }
    }

    @discardableResult
    func updateDeadlineAt(_ value: Date?) -> IndexPath? {
        updateUniqueCellVM(section: .fields) { (cellVM: DeadlineDateCellViewModel) -> DeadlineDateCellViewModel in
            var updatedCellVM = cellVM
            updatedCellVM.date = value
            return updatedCellVM
        }
    }

    @discardableResult
    func updateReminderDate(_ value: Date?) -> IndexPath? {
        updateUniqueCellVM(section: .fields) { (cellVM: ReminderDateCellViewModel) -> ReminderDateCellViewModel in
            var updatedCellVM = cellVM
            updatedCellVM.dateTime = value
            return updatedCellVM
        }
    }

    @discardableResult
    func updateRepeatPeriod(_ value: String?) -> IndexPath? {
        updateUniqueCellVM(section: .fields) { (cellVM: RepeatPeriodCellViewModel) -> RepeatPeriodCellViewModel in
            var updatedCellVM = cellVM
            updatedCellVM.period = value
            return updatedCellVM
        }
    }

    @discardableResult
    func addFileCellVM(_ file: TaskFile, withNotify: Bool = true) -> IndexPath? {
        let fileCellVM = FileCellViewModel(
            id: file.id!,
            name: file.fileName!,
            fileExtension: file.fileExtension!,
            size: Int(file.fileSize)
        )
        let indexPath = addCellVM(fileCellVM, to: .files, withNotify: withNotify)

        return indexPath
    }

    @discardableResult
    func deleteFile(with indexPath: IndexPath) -> IndexPath? {
        deleteCellVM(with: indexPath, from: .files)
    }

    @discardableResult
    func updateDescription(text: NSAttributedString?, updatedAt: Date?) -> IndexPath? {
        updateUniqueCellVM(section: .description) {
            (cellVM: DescriptionCellViewModel) -> DescriptionCellViewModel in
            var updatedCellVM = cellVM
            updatedCellVM.text = text
            updatedCellVM.updatedAt = updatedAt
            return updatedCellVM
        }
    }

}

// MARK: - Private Helpers

private extension TaskDetailTableViewModel {

    @inline(__always)
    func getSectionCells(_ section: Section) -> [TaskDetailTableCellViewModelType]? {
        return viewModels[safe: section.rawValue] ?? nil
    }

    // MARK: Helpers Universal

    func addCellVM(
        _ cellVM: TaskDetailTableCellViewModelType,
        to sectionIndex: Section,
        withNotify: Bool = true
    ) -> IndexPath? {
        let sectionIndexRaw = sectionIndex.rawValue
        var resultIndexPath: IndexPath?

        if viewModels.hasIndex(sectionIndexRaw) {
            viewModels[sectionIndexRaw].append(cellVM)

            let rowIndex = viewModels[sectionIndexRaw].count - 1
            resultIndexPath = IndexPath(row: rowIndex, section: sectionIndexRaw)
        }

        if let resultIndexPath, withNotify {
            updateEventRelay.accept(.addCell(to: resultIndexPath, cellVM: cellVM))
        } else if resultIndexPath == nil {
#if DEBUG
            print("## Не удалось добавить ячейку в TaskDetailTable: \(sectionIndex), \(cellVM))")
#endif
        }

        return resultIndexPath
    }

    func updateUniqueCellVM<T: TaskDetailTableCellViewModelType>(
        section: Section,
        updateCellVM: (T) -> T
    ) -> IndexPath? {
        let sectionIndex = section.rawValue
        let hasIndex = viewModels.hasIndex(sectionIndex)

        var result: (indexPath: IndexPath, cellVM: T)?

        if hasIndex, let cellsViewModels = getSectionCells(section) {
            for (rowIndex, cellVM) in cellsViewModels.enumerated() {
                if let cellVM = cellVM as? T {
                    let updatedCellVM = updateCellVM(cellVM)
                    viewModels[sectionIndex][rowIndex] = updatedCellVM

                    result = (
                        indexPath: IndexPath(row: rowIndex, section: sectionIndex),
                        cellVM: updatedCellVM
                    )
                    break
                }
            }
        }

        if let result {
            updateEventRelay.accept(
                .updateCell(with: result.indexPath, cellVM: result.cellVM)
            )
        } else {
#if DEBUG
            print("## Не удалось обновить ячейку TaskDetailTable: \(section), \(T.self))")
#endif
        }

        return result?.indexPath
    }

    func deleteCellVM(with indexPath: IndexPath, from section: Section) -> IndexPath? {
        let sectionIndex = section.rawValue
        let deletingRowIndex = indexPath.row

        var resultIndexPath: IndexPath?
        if viewModels.hasIndex(sectionIndex),
           viewModels[sectionIndex].hasIndex(deletingRowIndex) {
            viewModels[sectionIndex].remove(at: deletingRowIndex)
            resultIndexPath = IndexPath(row: deletingRowIndex, section: sectionIndex)
        }

        if let resultIndexPath {
            updateEventRelay.accept(
                .removeCells(with: [resultIndexPath])
            )
        } else {
#if DEBUG
            print("## Не удалось удалить ячейку в TaskDetailTable: \(sectionIndex), \(indexPath))")
#endif
        }

        return resultIndexPath
    }

    // MARK: Helpers Wrappers

    @discardableResult
    func addCreateSubtaskCellVM(withNotify: Bool = true) -> IndexPath? {
        addCellVM(CreateSubtaskCellViewModel(), to: .subtasks, withNotify: withNotify)
    }

    @discardableResult
    func addInToMyDayCellVM(_ value: Bool, withNotify: Bool = true) -> IndexPath?  {
        addCellVM(
            AddToMyDayCellViewModel(inMyDay: value),
            to: .fields,
            withNotify: withNotify
        )
    }

    @discardableResult
    func addReminderDateCellVM(_ value: Date?, withNotify: Bool = true) -> IndexPath?  {
        addCellVM(
            ReminderDateCellViewModel(dateTime: value),
            to: .fields,
            withNotify: withNotify
        )
    }

    @discardableResult
    private func addDeadlineDateCellVM(_ value: Date?, withNotify: Bool = true) -> IndexPath? {
        addCellVM(
            DeadlineDateCellViewModel(date: value),
            to: .fields,
            withNotify: withNotify
        )
    }

    @discardableResult
    func addRepeatPeriodCellVM(_ value: String?, withNotify: Bool = true) -> IndexPath? {
        addCellVM(
            RepeatPeriodCellViewModel(period: value),
            to: .fields,
            withNotify: withNotify
        )
    }

    @discardableResult
    func addImportFileCellVM(withNotify: Bool = true) -> IndexPath? {
        addCellVM(
            ImportFileCellViewModel(),
            to: .files,
            withNotify: withNotify
        )
    }

    @discardableResult
    func addDescriptionCellVM(
        text: NSAttributedString?,
        dateUpdatedAt: Date?,
        withNotify: Bool = true
    ) -> IndexPath? {
        addCellVM(
            DescriptionCellViewModel(
                text: text,
                dateUpdatedAt: dateUpdatedAt
            ),
            to: .description,
            withNotify: withNotify
        )
    }
}
