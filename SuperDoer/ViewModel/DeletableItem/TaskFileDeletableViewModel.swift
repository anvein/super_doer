
import Foundation

class TaskFileDeletableViewModel: BaseDeletableItemViewModel {
    
    class override var typeName: ItemTypeName  {
        return ItemTypeName(
            oneIP: "файл",
            oneVP: "файл",
            manyVP: "файлы"
        )
    }
    
    static func createFrom(fileCellViewModel: FileCellViewModel, indexPath: IndexPath) -> TaskFileDeletableViewModel {
        return TaskFileDeletableViewModel(
            title: fileCellViewModel.name,
            indexPath: indexPath
        )
    }
}
