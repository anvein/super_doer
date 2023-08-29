
import UIKit

/// Попап-контроллер для установки даты выполнения задачи
class PageSheetDealineViewController: UIViewController {

    init() {
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = .systemOrange
//
//        // делегат, который обрабатывает "сообщения" связанные с попапом
//
//        sheetPresentationController?.delegate = self
        
        // размер контроллера по-умолчанию
//        sheetPresentationController?.selectedDetentIdentifier = .large
        
        // массив с допустимыми параметрами высоты контроллера
        sheetPresentationController?.detents = [
                        .custom(resolver: { context in
                            return 250
                        }),
            .large(),
            .medium(),
        ]
        
        // false (default) - контроллер будет отображаться в полноэкранном режиме с "компактной высотой" (в горизонтальной ориентации)
        // true - будет не на полный экран, а с отступами (в горизонтальной ориентации, "компактной высотой")
        sheetPresentationController?.prefersEdgeAttachedInCompactHeight = true
        
        sheetPresentationController?.widthFollowsPreferredContentSizeWhenEdgeAttached = true

        sheetPresentationController?.prefersGrabberVisible = true
        
        

    }
    
    
    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        self.sheetPresentationController?.invalidateDetents()
    }
    
//    
//    func adaptivePresentationStyle(for controller: UIPresentationController) -> UIModalPresentationStyle {
//        return .none
//    }
//    
//    
//    func popoverPresentationControllerShouldDismissPopover(_ popoverPresentationController: UIPopoverPresentationController) -> Bool {
//        return true
//    }
//    
    



}
