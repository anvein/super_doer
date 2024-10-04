
import Foundation

/// Структура содержащая ячейки ViewModel хранящие данные задачи для таблицы
struct TaskDetailDataCellViewModels {

    // TODO: добавить доступ через сабскрипт?)
    
    private var viewModels: [[TaskDetailDataCellViewModelType]] = Array(repeating: [], count: 4)


    // MARK: - Init

    init(_ task: CDTask) {
        fill(from: task)
    }

    // MARK: - View Models getters

    var countSections: Int { viewModels.count }

    func getCountRowsInSection(_ section: Int) -> Int {
        return section >= 0 && section < viewModels.count ? viewModels[section].count : 0
    }

    func getCellVM(for indexPath: IndexPath) -> TaskDetailDataCellViewModelType? {
        return viewModels[safe: indexPath.section]?[indexPath.row]
    }

    // MARK: - Fill and Update View Models

    /// Полностью обновляет все данные для таблицы на основании task
    mutating func fill(from task: CDTask) {
        viewModels = Array(repeating: [], count: 4)

        addCellVM(AddSubTaskCellViewModel(), to: .subtasks)

        addCellVM(AddToMyDayCellViewModel(inMyDay: task.inMyDay), to: .fields)
        addCellVM(ReminderDateCellViewModel(dateTime: task.reminderDateTime), to: .fields)
        addCellVM(DeadlineDateCellViewModel(date: task.deadlineDate), to: .fields)
        addCellVM(RepeatPeriodCellViewModel(period: task.repeatPeriod), to: .fields)

        addCellVM(AddFileCellVeiwModel(), to: .files)
        
        for file in task.files ?? []  {
            guard let file = file as? TaskFile else { continue }

            addFile(file)
        }

        addCellVM(
            DescriptionCellViewModel(contentAsHtml: task.descriptionText, dateUpdatedAt: task.descriptionUpdatedAt),
            to: .description
        )
    }
    
    mutating func fillAddToMyDay(from task: CDTask) -> IndexPath? {
        guard let fieldsCellsVMs = getSectionCells(.fields) else { return nil }
        let sectionIndex = SectionIndex.fields.rawValue

        for (rowIndex, cellVM) in fieldsCellsVMs.enumerated() {
            if var addToMyDayCellVM = cellVM as? AddToMyDayCellViewModel {
                addToMyDayCellVM.inMyDay = task.inMyDay
                viewModels[sectionIndex][rowIndex] = addToMyDayCellVM

                return IndexPath(row: rowIndex, section: sectionIndex)
            }
        }
        
        return nil
    }

    mutating func fillDeadlineAt(from task: CDTask) -> IndexPath? {
        guard let fieldsCellsVMs = getSectionCells(.fields) else { return nil }
        let sectionIndex = SectionIndex.fields.rawValue

        for (rowIndex, cellVM) in fieldsCellsVMs.enumerated() {
            if var deadlineAtCellVM = cellVM as? DeadlineDateCellViewModel {
                deadlineAtCellVM.date = task.deadlineDate
                viewModels[sectionIndex][rowIndex] = deadlineAtCellVM

                return IndexPath(row: rowIndex, section: sectionIndex)
            }
        }

        return nil
    }

    mutating func fillReminderDate(from task: CDTask) -> IndexPath? {
        guard let fieldsCellsVMs = getSectionCells(.fields) else { return nil }
        let sectionIndex = SectionIndex.fields.rawValue

        for (rowIndex, cellVM) in fieldsCellsVMs.enumerated() {
            if var reminderDateCellVM = cellVM as? ReminderDateCellViewModel {
                reminderDateCellVM.dateTime = task.reminderDateTime
                viewModels[sectionIndex][rowIndex] = reminderDateCellVM

                return IndexPath(row: rowIndex, section: sectionIndex)
            }
        }

        return nil
    }

    mutating func fillRepeatPeriod(from task: CDTask) -> IndexPath? {
        guard let fieldsCellsVMs = getSectionCells(.fields) else { return nil }
        let sectionIndex = SectionIndex.fields.rawValue

        for (rowIndex, cellVM) in fieldsCellsVMs.enumerated() {
            if var cellVM = cellVM as? RepeatPeriodCellViewModel {
                cellVM.period = task.repeatPeriod
                viewModels[sectionIndex][rowIndex] = cellVM

                return IndexPath(row: rowIndex, section: sectionIndex)
            }
        }

        return nil
    }

    @discardableResult
    mutating func addFile(_ file: TaskFile) -> IndexPath? {
        let fileCellVM = FileCellViewModel(
            id: file.id!,
            name: file.fileName!,
            fileExtension: file.fileExtension!,
            size: Int(file.fileSize)
        )
        let indexPath = addCellVM(fileCellVM, to: .files)

        return indexPath
    }

    @discardableResult
    mutating func deleteFile(with indexPath: IndexPath) -> Bool {
        let deletingRowIndex = indexPath.row
        guard var fieldsCellsVMs = getSectionCells(.fields),
              0 <= deletingRowIndex,
              deletingRowIndex < fieldsCellsVMs.count else { return false }
        let sectionIndex = SectionIndex.fields.rawValue

        fieldsCellsVMs.remove(at: deletingRowIndex)
        viewModels[sectionIndex] = fieldsCellsVMs

        return true
    }

    mutating func fillDescription(from task: CDTask) -> IndexPath? {
        guard let fieldsCellsVMs = getSectionCells(.description) else { return nil }
        let sectionIndex = SectionIndex.description.rawValue

        for (rowIndex, cellVM) in fieldsCellsVMs.enumerated() {
            if var descriptionCellVM = cellVM as? DescriptionCellViewModel {
                // TODO: сконвертировать нормально хранимый string в NSAttributedString
                if let safeContent = task.descriptionText {
                    descriptionCellVM.content = NSAttributedString(string: safeContent)
                } else {
                    descriptionCellVM.content = nil
                }
                descriptionCellVM.updatedAt = task.descriptionUpdatedAt
                viewModels[sectionIndex][rowIndex] = descriptionCellVM

                return IndexPath(row: rowIndex, section: sectionIndex)
            }
        }
        
        return nil
    }

    // MARK: - Helpers

    @discardableResult
    private mutating func addCellVM(
        _ cellVM: TaskDetailDataCellViewModelType,
        to sectionIndex: SectionIndex
    ) -> IndexPath? {
        let sectionIndexRaw = sectionIndex.rawValue
        guard sectionIndexRaw < viewModels.count else { return nil }
        viewModels[sectionIndexRaw].append(cellVM)
        let rowIndex = viewModels[sectionIndexRaw].count - 1

        return IndexPath(row: rowIndex, section: sectionIndexRaw)
    }

    @inline(__always)
    private func getSectionCells(_ section: SectionIndex) -> [TaskDetailDataCellViewModelType]? {
        return viewModels[safe: section.rawValue] ?? nil
    }
}

// MARK: - TaskDetailDataCellViewModels.SectionIndex

extension TaskDetailDataCellViewModels {
    enum SectionIndex: Int {
        case subtasks = 0
        case fields = 1
        case files = 2
        case description = 3
    }
}
