import UIKit

class ImportFileSourceAlertFactory {
    typealias OnSelectAnswerCallback = ((ImportFileSourceAlertAnswer) -> Void)

    func makeAlert(
        onSelectAnswer: OnSelectAnswerCallback?
    ) -> UIAlertController {
        let alert = UIAlertController(
            title: "Добавить файл из",
            message: nil,
            preferredStyle: .actionSheet
        )

        alert.addAction(createAction(title: "Библиотека изображений", source: .library, onSelect: onSelectAnswer))
        alert.addAction(createAction(title: "Камера", source: .camera, onSelect: onSelectAnswer))
        alert.addAction(createAction(title: "Файлы", source: .files, onSelect: onSelectAnswer))
        alert.addAction(
            UIAlertAction(title: "Отмена", style: .cancel) { _ in
                onSelectAnswer?(.cancel)
            }
        )

        return alert
    }

    private func createAction(
        title: String,
        source: ImportFileSource,
        onSelect: OnSelectAnswerCallback?
    ) -> UIAlertAction {
        return UIAlertAction(title: title, style: .default) { _ in
            onSelect?(.selectedSource(source))
        }
    }
}
