
protocol TaskDetailVCCoordinatorDelegate: AnyObject {
    /// Тап по ячейке с датой напоминания по задаче
    func taskDetailVCReminderDateSetterOpen()

    /// Тап по ячейке с датой дедлайна задачи
    func taskDetailVCDeadlineDateSetterOpen()

    /// Тап по ячейке с периодом повтора задачи
    func taskDetailVCRepeatPeriodSetterOpen()

    // Тап по ячейке с описанием задачи
    func taskDetailVCDecriptionEditorOpen()

    // Тап по ячейке "добавления файла"
    func taskDetailVCAddFileStart()

    /// Пользователь начал "удалять задачу"
    func taskDetailVCStartDeleteProcessFile(viewModel: TaskFileDeletableViewModel)

    /// Задача закрыта (ушли с экрана просмотра / редактирования задачи)
    func taskDetailVCDidCloseTaskDetail()

}
