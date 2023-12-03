
import Foundation

/// Класс хранящий данные задачи в подходящем формате для заполения таблицы
class TaskDataCellValues {
    // TODO: добавить доступ через сабскрипт?)
    
    var cellsValuesArray = [TaskDataCellValueProtocol]()
    
    /// Полностью обновляет все данные для таблицы на основании task
    func fill(from task: Task) {
        cellsValuesArray.removeAll()
        
        cellsValuesArray.append(AddSubTaskCellValue())
        // TODO: подзадачи
        
        cellsValuesArray.append(AddToMyDayCellValue(inMyDay: task.inMyDay))
        cellsValuesArray.append(RemindCellValue(dateTime: task.reminderDateTime))
        
        cellsValuesArray.append(DeadlineCellValue(date: task.deadlineDate))
        cellsValuesArray.append(RepeatCellValue())
        cellsValuesArray.append(AddFileCellValue())
        
        
        for file in task.files ?? []  {
            guard let taskFile = file as? TaskFile else {
                // TODO: залогировать ошибку
                continue
            }
            
            cellsValuesArray.append(
                FileCellValue(
                    id: taskFile.id!,
                    name: taskFile.fileName!,
                    fileExtension: taskFile.fileExtension!,
                    size: Int(taskFile.fileSize)
                )
            )
        }
        
        cellsValuesArray.append(
            DescriptionCellValue(contentAsHtml: task.taskDescription, dateUpdatedAt: task.descriptionUpdatedAt)
        )
    }
    
    func fillAddToMyDay(from task: Task) {
        for (index, buttonValue) in cellsValuesArray.enumerated() {
            if var addToMyDayCellValue = buttonValue as? AddToMyDayCellValue {
                addToMyDayCellValue.inMyDay = task.inMyDay

                cellsValuesArray[index] = addToMyDayCellValue
                break
            }
        }
    }
    
    func fillDeadlineAt(from task: Task) {
        for (index, buttonValue) in cellsValuesArray.enumerated() {
            if var deadlineAtCellValue = buttonValue as? DeadlineCellValue {
                deadlineAtCellValue.date = task.deadlineDate

                cellsValuesArray[index] = deadlineAtCellValue
                break
            }
        }
    }
    
    func appendFile(_ file: TaskFile) -> RowIndex {
        let indexOfLastFile = getIndexOfLastFileOrAddFileButton()
        
        guard let safeIndexOfLastFile = indexOfLastFile else {
            print("no index")
            // TODO: надо кинуть ошибку или залогировать т.к файл или кнопка добавить файл точно должна быть
            return 0
        }
        let indexNewFile = safeIndexOfLastFile + 1
        
        cellsValuesArray.insert(
            FileCellValue(
                id: file.id!,
                name: file.fileName!,
                fileExtension: file.fileExtension!,
                size: Int(file.fileSize)
            ),
            at: indexNewFile
        )
        
        return indexNewFile
    }
    
    func fillDescription(from task: Task) {
        for (index, buttonValue) in cellsValuesArray.enumerated() {
            if var descriptionCellValue = buttonValue as? DescriptionCellValue {
                // TODO: сконвертировать нормально хранимый string в NSAttributedString
                if let safeContent = task.taskDescription {
                    descriptionCellValue.content = NSAttributedString(string: safeContent)
                } else {
                    descriptionCellValue.content = nil
                }
                descriptionCellValue.updatedAt = task.descriptionUpdatedAt

                cellsValuesArray[index] = descriptionCellValue
                break
            }
        }
    }
    
    
    private func getIndexOfLastFileOrAddFileButton() -> Int? {
        var result: Int? = nil
        for (index, cellValue) in cellsValuesArray.enumerated() {
            if cellValue is AddFileCellValue || cellValue is FileCellValue {
                result = index
            }
        }
        
        return result
    }
}

typealias RowIndex = Int

