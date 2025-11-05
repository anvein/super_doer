import UIKit

enum TableVariantsControllerDetent {
    case taskDeadlineVariants
    case taskRepeatPeriodVariants

    var defaultHeight: CGFloat {
        switch self {
        case .taskDeadlineVariants: 280
        case .taskRepeatPeriodVariants: 380
        }
    }

    var identifier: UISheetPresentationController.Detent.Identifier {
        switch self {
        case .taskDeadlineVariants: .taskDeadlineVariants
        case .taskRepeatPeriodVariants: .taskRepeatPeriodVariants
        }
    }

    var detent: UISheetPresentationController.Detent {
        .custom(identifier: identifier) { _ in defaultHeight }
    }

}

extension UISheetPresentationController.Detent.Identifier {
    static let taskDeadlineVariants: SheetDetentIdentifier = SheetDetentIdentifier("taskDeadlineVariants")
    static let taskRepeatPeriodVariants: SheetDetentIdentifier = SheetDetentIdentifier("taskRepeatPeriodVariants")
}
