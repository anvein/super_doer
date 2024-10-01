
protocol TaskDetailVCCoordinatorDelegate: AnyObject {
    /// Тап по ячейке с датой напоминания по задаче
    func taskDetailVCDidTapReminderDateCell()

    /// Тап по ячейке с датой дедлайна задачи
    func taskDetailVCDidTapDeadlineDateCell()

    /// Тап по ячейке с периодом повтора задачи
    func taskDetailVCDidTapRepeatPeriodCell()

    // Тап по ячейке с описанием задачи
    func taskDetailVCDidTapDecriptionCell()

    // Тап по ячейке "добавления файла"
    func taskDetailVCDidTapAddFileCell()

    /// Пользователь начал "удалять задачу"
    func taskDetailVCStartDeleteProcessFile(viewModel: TaskFileDeletableViewModel)

    /// Задача закрыта (ушли с экрана просмотра / редактирования задачи)
    func taskDetailVCDidCloseTaskDetail()

}
