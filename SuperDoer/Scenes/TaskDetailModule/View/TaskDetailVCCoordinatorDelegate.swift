
protocol TaskDetailVCCoordinatorDelegate: AnyObject {
    /// Тап по ячейке с датой напоминания по задаче
    func tapReminderDateCell()

    /// Тап по ячейке с датой дедлайна задачи
    func tapDeadlineDateCell()

    /// Тап по ячейке с периодом повтора задачи
    func tapRepeatPeriodCell()

    // Тап по ячейке с описанием задачи
    func tapDecriptionCell()

    // Тап по ячейке "добавления файла"
    func tapAddFileCell()

    /// Пользователь начал "удалять задачу"
    func startDeleteProcessFile(viewModel: TaskFileDeletableViewModel)

    /// Задача закрыта (ушли с экрана просмотра / редактирования задачи)
    func closeTaskDetail()

}
