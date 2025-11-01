protocol ImportFileSourceAlertDelegate: AnyObject {
    func didChooseImportFileSource(_ source: ImportFileSourceAlertFactory.FileSource)
    func didChooseImportFileSourceCancel()
}
