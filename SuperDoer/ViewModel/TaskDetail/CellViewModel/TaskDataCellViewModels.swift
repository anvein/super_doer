
import Foundation

/// Структура содержащая ячейки ViewModel хранящие данные задачи для таблицы
struct TaskDataCellViewModels {
    typealias RowIndex = Int
    
    // TODO: добавить доступ через сабскрипт?)
    
    var viewModels = [TaskDataCellViewModelType]()
    
    init(_ task: CDTask) {
        fill(from: task)
    }
    
    /// Полностью обновляет все данные для таблицы на основании task
    mutating func fill(from task: CDTask) {
        viewModels.removeAll()
        
        viewModels.append(AddSubTaskCellViewModel())
        // TODO: подзадачи
        
        viewModels.append(AddToMyDayCellViewModel(inMyDay: task.inMyDay))
        viewModels.append(ReminderDateCellViewModel(dateTime: task.reminderDateTime))
        
        viewModels.append(DeadlineDateCellViewModel(date: task.deadlineDate))
        viewModels.append(RepeatPeriodCellViewModel(period: task.repeatPeriod))
        viewModels.append(AddFileCellVeiwModel())
        
        
        for file in task.files ?? []  {
            guard let taskFile = file as? TaskFile else {
                // TODO: залогировать ошибку
                continue
            }
            
            viewModels.append(
                FileCellViewModel(
                    id: taskFile.id!,
                    name: taskFile.fileName!,
                    fileExtension: taskFile.fileExtension!,
                    size: Int(taskFile.fileSize)
                )
            )
        }
        
        viewModels.append(
            DescriptionCellViewModel(contentAsHtml: task.taskDescription, dateUpdatedAt: task.descriptionUpdatedAt)
        )
    }
    
    mutating func fillAddToMyDay(from task: CDTask) -> RowIndex? {
        for (index, buttonValue) in viewModels.enumerated() {
            if var addToMyDayCellValue = buttonValue as? AddToMyDayCellViewModel {
                addToMyDayCellValue.inMyDay = task.inMyDay
                viewModels[index] = addToMyDayCellValue
                
                return index
            }
        }
        
        return nil
    }
    
    mutating func fillDeadlineAt(from task: CDTask) -> RowIndex? {
        for (index, buttonValue) in viewModels.enumerated() {
            if var deadlineAtCellValue = buttonValue as? DeadlineDateCellViewModel {
                deadlineAtCellValue.date = task.deadlineDate
                viewModels[index] = deadlineAtCellValue
                
                return index
            }
        }
        
        return nil
    }
    
    mutating func fillReminderDateTime(from task: CDTask) -> RowIndex? {
        for (index, buttonValue) in viewModels.enumerated() {
            if var reminderDateTimeCellValue = buttonValue as? ReminderDateCellViewModel {
                reminderDateTimeCellValue.dateTime = task.reminderDateTime
                viewModels[index] = reminderDateTimeCellValue
                
                return index
            }
        }
        
        return nil
    }
    
    mutating func fillRepeatPeriod(from task: CDTask) -> RowIndex? {
        for (index, buttonValue) in viewModels.enumerated() {
            if var repeatPeriodCellValue = buttonValue as? RepeatPeriodCellViewModel {
                repeatPeriodCellValue.period = task.repeatPeriod
                viewModels[index] = repeatPeriodCellValue
                
                return index
            }
        }
        
        return nil
    }
    
    mutating func appendFile(_ file: TaskFile) -> RowIndex {
        let indexOfLastFile = getIndexOfLastFileOrAddFileButton()
        
        guard let safeIndexOfLastFile = indexOfLastFile else {
            print("no index")
            // TODO: надо кинуть ошибку или залогировать т.к файл или кнопка добавить файл точно должна быть
            return 0
        }
        let indexNewFile = safeIndexOfLastFile + 1
        
        viewModels.insert(
            FileCellViewModel(
                id: file.id!,
                name: file.fileName!,
                fileExtension: file.fileExtension!,
                size: Int(file.fileSize)
            ),
            at: indexNewFile
        )
        
        return indexNewFile
    }
    
    mutating func fillDescription(from task: CDTask) -> RowIndex? {
        for (index, buttonValue) in viewModels.enumerated() {
            if var descriptionCellValue = buttonValue as? DescriptionCellViewModel {
                // TODO: сконвертировать нормально хранимый string в NSAttributedString
                if let safeContent = task.taskDescription {
                    descriptionCellValue.content = NSAttributedString(string: safeContent)
                } else {
                    descriptionCellValue.content = nil
                }
                descriptionCellValue.updatedAt = task.descriptionUpdatedAt

                viewModels[index] = descriptionCellValue
                
                return index
            }
        }
        
        return nil
    }
    
    
    private func getIndexOfLastFileOrAddFileButton() -> Int? {
        var result: Int? = nil
        for (index, cellValue) in viewModels.enumerated() {
            if cellValue is AddFileCellVeiwModel || cellValue is FileCellViewModel {
                result = index
            }
        }
        
        return result
    }
}





// MARK: TaskData classes
protocol TaskDataCellViewModelType {
    
}

struct AddToMyDayCellViewModel: TaskDataCellViewModelType {
    var inMyDay: Bool = false
}

struct SubTaskCellViewModel: TaskDataCellViewModelType {
    var isCompleted: Bool = false
    var title: String
}

struct AddSubTaskCellViewModel: TaskDataCellViewModelType {
    
}

struct ReminderDateCellViewModel: TaskDataCellViewModelType {
    var dateTime: Date?
}

struct DeadlineDateCellViewModel: TaskDataCellViewModelType {
    var date: Date?
}

struct RepeatPeriodCellViewModel: TaskDataCellViewModelType {
    // TODO: переделать тип
    var period: String?
}

struct AddFileCellVeiwModel: TaskDataCellViewModelType {
    
}

struct FileCellViewModel: TaskDataCellViewModelType {
    var id: UUID
    var name: String
    var fileExtension: String
    var size: Int
    
    var titleForDelete: String {
        return name
    }
}


struct DescriptionCellViewModel: TaskDataCellViewModelType {
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
