import UIKit

class AddFileSourceAlertFactory {

    enum FileSource {
        case library
        case camera
        case files
    }

    func makeAlert(
        delegate: AddFileSourceAlertDelegate
    ) -> UIAlertController {
        let alert = UIAlertController(
            title: "Добавить файл из",
            message: nil,
            preferredStyle: .actionSheet
        )

        alert.addAction(createAction(title: "Библиотека изображений", source: .library, delegate: delegate))
        alert.addAction(createAction(title: "Камера", source: .camera, delegate: delegate))
        alert.addAction(createAction(title: "Файлы", source: .files, delegate: delegate))
        alert.addAction(UIAlertAction(title: "Отмена", style: .cancel) { _ in
            delegate.didChooseImportFileSourceCancel()
        })

        return alert
    }

    private func createAction(
        title: String,
        source: FileSource,
        delegate: AddFileSourceAlertDelegate
    ) -> UIAlertAction {
        return UIAlertAction(title: title, style: .default) { _ in
            switch source {
            case .library:
                delegate.didChooseImportFileSource(.library)
            case .camera:
                delegate.didChooseImportFileSource(.camera)
            case .files:
                delegate.didChooseImportFileSource(.files)
            }
        }
    }
}
