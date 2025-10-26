import Foundation

class TaskSectionDeletableViewModel: BaseDeletableItemViewModel {
    
    class override var typeName: ItemTypeName  {
        return ItemTypeName(
            oneIP: "список",
            oneVP: "список",
            manyVP: "списки"
        )
    }
    
    static func createFrom(section: CDTaskCustomSection, indexPath: IndexPath) -> TaskSectionDeletableViewModel {
        return TaskSectionDeletableViewModel(
            title: section.title ?? "",
            indexPath: indexPath
        )
    }
}
