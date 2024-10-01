
import Foundation

protocol StandartTaskTableViewCellDelegate: AnyObject {
    func standartTaskCellDidTapIsDoneButton(indexPath: IndexPath)
    func standartTaskCellDidTapIsPriorityButton(indexPath: IndexPath)

}
