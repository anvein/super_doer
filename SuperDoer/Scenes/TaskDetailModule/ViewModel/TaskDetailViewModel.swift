
import Foundation

class TaskDetailViewModel {
    
    // MARK: model
    private var task: CDTask {
        didSet {
            updateSimpleObservablePropertiesFrom(task)
            taskDataViewModels.fill(from: task)
        }
    }
    
    // TODO: - Services

    private var taskEm = TaskCoreDataManager()
    private var taskFileEm = TaskFileEntityManager()
    
    
    // MARK: properties for VC
    /// Объект-массив на основании которого формируется таблица с "кнопками" и данными задачи
    /// Прослойка между сущностью Task и данных для вывода задачи в виде таблицы
    private var taskDataViewModels: TaskDetailDataCellViewModels
    
    var countTaskDataCellsValues: Int {
        return taskDataViewModels.viewModels.count
    }
    
    var taskTitle: Box<String?>
    var taskIsCompleted: Box<Bool>
    var taskIsPriority: Box<Bool>
    
    var isEnableNotifications: Bool {
        
        // TODO: получить из сервиса, который вернет "включены ли уведомления"
        return true
    }
    
    weak var bindingDelegate: TaskDetailViewModelBindingDelegate?
    
    
    // MARK: - Init

    init(
        _ taskId: UUID,
        taskEm: TaskCoreDataManager,
        taskFileEm: TaskFileEntityManager
    ) {
        self.taskEm = taskEm
        self.taskFileEm = taskFileEm

        task = taskEm.getTaskBy(id: taskId)! // TODO: переделать это
        taskTitle = Box(task.title)
        taskIsCompleted = Box(task.isCompleted)
        taskIsPriority = Box(task.isPriority)
        
        taskDataViewModels = TaskDetailDataCellViewModels(task)
    }
    
    
    // MARK: children view models building
    func getTaskDataCellViewModelFor(indexPath: IndexPath) -> TaskDataCellViewModelType {
        return taskDataViewModels.viewModels[indexPath.row]
    }
    
    func getTaskDeadlineTableVariantsViewModel() -> TaskDeadlineTableVariantsViewModel {
        return TaskDeadlineTableVariantsViewModel(deadlineDate: task.deadlineDate)
    }
    
    func getTaskReminderCustomDateViewModel() -> TaskReminderCustomDateViewModel {
        return TaskReminderCustomDateViewModel(task: task)
    }
    
    func getTaskRepeatPeriodTableVariantsViewModel() -> TaskRepeatPeriodTableVariantsViewModel {
        return TaskRepeatPeriodTableVariantsViewModel(repeatPeriod: task.repeatPeriod)
    }
    
    func getFileCellViewModel(forIndexPath indexPath: IndexPath) -> FileCellViewModel? {
        let fileCellVM = taskDataViewModels.viewModels[indexPath.row]
        guard let fileCellVM = fileCellVM as? FileCellViewModel else { return nil }
        
        return fileCellVM
    }
    
    func getFileDeletableViewModelFor(_ indexPath: IndexPath) -> TaskFileDeletableViewModel? {
        let fileCellVM = taskDataViewModels.viewModels[indexPath.row]
        guard let fileCellVM = fileCellVM as? FileCellViewModel else { return nil }
        
        return TaskFileDeletableViewModel.createFrom(
            fileCellViewModel: fileCellVM,
            indexPath: indexPath
        )
    }
    
    func isFileCellViewModel(byIndexPath indexPath: IndexPath) -> Bool {
        return taskDataViewModels.viewModels[indexPath.row] is FileCellViewModel
    }
    
    func getTaskDescriptionEditorViewModel() -> TaskDescriptionEditorViewModel {
        return TaskDescriptionEditorViewModel(task: task)
    }
    
    
    // MARK: model manipulations
    func updateTaskField(title: String) {
        taskEm.updateField(title: title, task: task)
        
        updateSimpleObservablePropertiesFrom(task)
    }
    
    func updateTaskField(isCompleted: Bool) {
        taskEm.updateField(isCompleted: isCompleted, task: task)
        
        updateSimpleObservablePropertiesFrom(task)
    }
    
    func updateTaskField(isPriority: Bool) {
        taskEm.updateField(isPriority: isPriority, task: task)
        
        updateSimpleObservablePropertiesFrom(task)
    }

    func updateTaskField(inMyDay: Bool) {
        taskEm.updateField(inMyDay: inMyDay, task: task)
        
        let rowIndex = taskDataViewModels.fillAddToMyDay(from: task)
        
        guard let rowIndex else { return }
        updateBindedCell(withRowIndex: rowIndex)
    }
    
    func switchValueTaskFieldInMyDay() {
        let newValue = !task.inMyDay
        updateTaskField(inMyDay: newValue)
    }
    
    func updateTaskField(deadlineDate: Date?) {
        taskEm.updateField(deadlineDate: deadlineDate, task: task)
        
        let rowIndex = taskDataViewModels.fillDeadlineAt(from: task)
        
        guard let rowIndex else { return }
        updateBindedCell(withRowIndex: rowIndex)
    }
    
    func updateTaskField(reminderDateTime: Date?) {
        taskEm.updateField(reminderDateTime: reminderDateTime, task: task)
        
        let rowIndex = taskDataViewModels.fillReminderDateTime(from: task)
        
        guard let rowIndex else { return }
        updateBindedCell(withRowIndex: rowIndex)
    }
    
    func updateTaskField(repeatPeriod: String?) {
        taskEm.updateField(repeatPeriod: repeatPeriod, task: task)
        
        let rowIndex = taskDataViewModels.fillRepeatPeriod(from: task)
        
        guard let rowIndex else { return }
        updateBindedCell(withRowIndex: rowIndex)
    }
    
    func updateTaskField(descriptionText: NSAttributedString?) {
        // TODO: конвертировать из NSAttributedString в хранимый string
        taskEm.updateFields(
            descriptionText: descriptionText?.string,
            descriptionUpdatedAt: Date(),
            task: task
        )
        let rowIndex = taskDataViewModels.fillDescription(from: task)
        
        guard let rowIndex else { return }
        updateBindedCell(withRowIndex: rowIndex)
    }
    
    func createTaskFile(fromImageData imageData: NSData) {
        let taskFile = taskFileEm.createWith(
            fileName: "Фото размером \(imageData.count) kb",
            fileExtension: "jpg",
            fileSize: imageData.count,
            task: task
        )
        
        let rowIndex = taskDataViewModels.appendFile(taskFile)
        addBindedCell(withRowIndex: rowIndex)
    }
    
    func createTaskFile(fromUrl url: URL) {
        let taskFile = taskFileEm.createWith(
            fileName: "Файл размером ??? kb",
            fileExtension: url.pathExtension,
            fileSize: 0,
            task: task
        )
        
        let rowIndex = taskDataViewModels.appendFile(taskFile)
        addBindedCell(withRowIndex: rowIndex)
    }
    
    func deleteTaskFile(fileDeletableVM: TaskFileDeletableViewModel) {
        guard let indexPath = fileDeletableVM.indexPath else {
            // TODO: залогировать
            return
        }
        
        let cellValue = taskDataViewModels.viewModels[indexPath.row]
        guard let fileCellValue = cellValue as? FileCellViewModel else {
            // TODO: показать сообщение об ошибке (файл не получилось удалить)
            return
        }
        
        let taskFile = task.getFileBy(id: fileCellValue.id)
        guard let taskFile else  {
            // TODO: показать сообщение об ошибке (файл не получилось удалить)
            return
        }
        
        taskFileEm.delete(file: taskFile)
        taskDataViewModels.viewModels.remove(at: indexPath.row)
        
        bindingDelegate?.removeCells(withIndexPaths: [indexPath])
    }
    
    
    // MARK: binding methods
    private func updateSimpleObservablePropertiesFrom(_ task: CDTask) {
        if task.title != taskTitle.value {
            taskTitle.value = task.title
        }
        
        if task.isCompleted != taskIsCompleted.value {
            taskIsCompleted.value = task.isCompleted
        }
        
        if task.isPriority != taskIsPriority.value {
            taskIsPriority.value = task.isPriority
        }
    }
    
    private func updateBindedCell(
        withRowIndex rowIndex: TaskDetailDataCellViewModels.RowIndex
    ) {
        let indexPath =  IndexPath(row: rowIndex, section: 0)

        bindingDelegate?.updateCell(
            withIndexPath: indexPath,
            cellViewModel: getTaskDataCellViewModelFor(indexPath: indexPath)
        )
    }
    
    private func addBindedCell(
        withRowIndex rowIndex: TaskDetailDataCellViewModels.RowIndex
    ) {
        let indexPath = IndexPath(row: rowIndex, section: 0)
        bindingDelegate?.addCell(
            toIndexPath: indexPath,
            cellViewModel: getTaskDataCellViewModelFor(indexPath: indexPath)
        )
    }
}


// MARK: delegate protocol for update view (binding)
protocol TaskDetailViewModelBindingDelegate: AnyObject {
    func addCell(toIndexPath indexPath: IndexPath, cellViewModel: TaskDataCellViewModelType)
    
    func updateCell(withIndexPath indexPath: IndexPath, cellViewModel: TaskDataCellViewModelType)
    
    func removeCells(withIndexPaths indexPaths: [IndexPath])
}

