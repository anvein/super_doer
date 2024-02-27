
import Foundation

/// Структура хранящая данные задачи в подходящем формате для заполения таблицы
struct TaskDataCellValues {
    // TODO: добавить доступ через сабскрипт?)
    
    var cellsValuesArray = [TaskDataCellValueProtocol]()
    
    init(_ task: Task) {
        fill(from: task)
    }
    
    /// Полностью обновляет все данные для таблицы на основании task
    mutating func fill(from task: Task) {
        cellsValuesArray.removeAll()
        
        cellsValuesArray.append(AddSubTaskCellValue())
        // TODO: подзадачи
        
        cellsValuesArray.append(AddToMyDayCellValue(inMyDay: task.inMyDay))
        cellsValuesArray.append(ReminderDateCellValue(dateTime: task.reminderDateTime))
        
        cellsValuesArray.append(DeadlineDateCellValue(date: task.deadlineDate))
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
    
    mutating func fillAddToMyDay(from task: Task) {
        for (index, buttonValue) in cellsValuesArray.enumerated() {
            if var addToMyDayCellValue = buttonValue as? AddToMyDayCellValue {
                addToMyDayCellValue.inMyDay = task.inMyDay

                cellsValuesArray[index] = addToMyDayCellValue
                break
            }
        }
    }
    
    mutating func fillDeadlineAt(from task: Task) {
        for (index, buttonValue) in cellsValuesArray.enumerated() {
            if var deadlineAtCellValue = buttonValue as? DeadlineDateCellValue {
                deadlineAtCellValue.date = task.deadlineDate

                cellsValuesArray[index] = deadlineAtCellValue
                break
            }
        }
    }
    
    mutating func fillReminderDateTime(from task: Task) {
        for (index, buttonValue) in cellsValuesArray.enumerated() {
            if var reminderDateTimeCellValue = buttonValue as? ReminderDateCellValue {
                reminderDateTimeCellValue.dateTime = task.reminderDateTime

                cellsValuesArray[index] = reminderDateTimeCellValue
                break
            }
        }
    }
    
    mutating func appendFile(_ file: TaskFile) -> RowIndex {
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
    
    mutating func fillDescription(from task: Task) {
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




// MARK: TaskData classes
protocol TaskDataCellValueProtocol {
    
}

struct AddToMyDayCellValue: TaskDataCellValueProtocol {
    var inMyDay: Bool = false
}

struct SubTaskCellValue: TaskDataCellValueProtocol {
    var isCompleted: Bool = false
    var title: String
}

struct AddSubTaskCellValue: TaskDataCellValueProtocol {
    
}

struct ReminderDateCellValue: TaskDataCellValueProtocol {
    var dateTime: Date?
}

struct DeadlineDateCellValue: TaskDataCellValueProtocol {
    var date: Date?
}

struct RepeatCellValue: TaskDataCellValueProtocol {
    // TODO: определить параметры
}

struct AddFileCellValue: TaskDataCellValueProtocol {
    
}

struct FileCellValue: TaskDataCellValueProtocol {
    var id: UUID
    var name: String
    var fileExtension: String
    var size: Int
}


struct DescriptionCellValue: TaskDataCellValueProtocol {
    var content: NSAttributedString?
    var updatedAt: Date?
    
    init(contentAsHtml: String? = nil, dateUpdatedAt: Date? = nil) {
        self.content = convertToNsAttributedStringFrom(contentAsHtml: contentAsHtml)
        self.updatedAt = dateUpdatedAt
    }
    
    private func convertToNsAttributedStringFrom(contentAsHtml: String?) -> NSAttributedString? {
//        self.content = NSAttributedString(string: "", attributes: []).data(from: 0..<contentAsHtml.len, documentAttributes: <#T##[NSAttributedString.DocumentAttributeKey : Any]#>)
//        NSAttributedString().data(from: 0.., documentAttributes: <#T##[NSAttributedString.DocumentAttributeKey : Any]#>)
//
//        NSAttributedString(data: Data(), documentAttributes: <#T##AutoreleasingUnsafeMutablePointer<NSDictionary?>?#>)
        
        if let filledContentAsHtml = contentAsHtml {
            return NSAttributedString(string: filledContentAsHtml)
        } else {
            return nil
        }
    }
}
