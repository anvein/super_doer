import Foundation
import UIKit
import RxSwift

/// BaseCoordinator
///
/// Использование:
/// 1. Надо переопределить:
///  - rootViewController
///  - setup() - при необходимости для настройки координатора и связанных компонентов
///  - navigate() - при необходимости для написания логики после старта координатора (старт дочерних и т.д.)
/// 2. Для старта надо вызвать start() или startChild() с замыканием в котором надо показать контроллер запускаемого координатора
///
/// - Note: 1. finish() и удаление координатора из parent.childs делать не надо - срабатывает само при закрытии контроллера (если не переопределен isAutoFinishEnabled)
/// - Note: 2. Отправлять события с результатом в finishResult (или по другому возвращать результат родителю надо до закрытия контроллера)
/// Иначе координатор при закрытии контроллера может завершиться раньше finish() и деинициализируется - из-за чего событие
///  с результатом не успеет пройти
class BaseCoordinator: NSObject, Coordinator {
    typealias RootController = UIViewController

    let disposeBag = DisposeBag()

    var childs: [Coordinator] = []
    weak var parent: Coordinator?
    var rootViewController: UIViewController {
        fatalError("\(self.description) need override rootViewController")
    }

    /// Флаг отвечающий за автоматическое завершение координатора при закрытии контроллера
    /// Надо переопределить со значением false, если необходимо чтобы координатор не завершался автоматически
    /// Если переопределен, то finish() надо вызывать вручную
    /// По умолчанию true
    var isAutoFinishEnabled: Bool { true }

    init(parent: Coordinator? = nil) {
        super.init()
        self.parent = parent
    }

    deinit {
        ConsoleLogger.log("## Deinit: \(self.description)")
    }

    final func start/*<RootController>*/(
        onPresent: (_ rootController: UIViewController) -> Void
    ) /*where RootController: UIViewController*/ {
        setup()
        onPresent(rootViewController)
        logStartCompleted()
        navigate()
    }

    /// Метод, который должен содержать код настройки координатора и компонентов связанных с ним (биндинг с VM / VC)
    func setup() {
        if isAutoFinishEnabled {
            rootViewController.didDismiss.emit(onNext: { [weak self] _ in
                self?.finish()
            })
            .disposed(by: disposeBag)
        }
    }

    /// Метод, который должен содержать логику навигации
    /// Выполняется после старта текущего координатора, его настройки и показа
    func navigate() { }

    /// Этот метод вызывать не надо самому в большинстве случаев
    /// надо только если isAutoFinishEnabled == false
    func finish() {
        parent?.removeChild(self)
        ConsoleLogger.log("## Did Finish: \(self.description)")
    }

    // MARK: - Helpers

    final func startChild(
        _ child: Coordinator,
        onPresent: (_ controller: UIViewController) -> Void
    ) {
        addChild(child)
        child.start { coordinatorRootVC in
            onPresent(coordinatorRootVC)
        }
    }

    private func logStartCompleted() {
        ConsoleLogger.log(
            "## Did Start: \(String(describing: self)) with \(self.rootViewController.description)"
        )
    }

}
