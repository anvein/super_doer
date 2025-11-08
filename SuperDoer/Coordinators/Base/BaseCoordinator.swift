import Foundation
import UIKit
import RxSwift

/// BaseCoordinator
///
/// Использование:
/// 1. Надо переопределить: rootViewController и startCoordinator()
/// 2. Для старта надо вызвать start()
///
/// Особенности:
/// 1. finish() и удаление координатора из parent.childs делать не надо - срабатывает само при закрытии контроллера (если не переопределен isAutoFinishEnabled)
/// 2. Отправлять событие с результатом в finishResult (или по другому возвращать результат родителю надо до закрытия контроллера)
/// Иначе координатор при закрытии контроллера может завершиться раньше finish() и деинициализируется - событие с результатом
/// не успеет пройти
class BaseCoordinator: NSObject, Coordinator {

    let disposeBag = DisposeBag()

    var childs: [Coordinator] = []
    weak var parent: Coordinator?
    var rootViewController: UIViewController? {
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

    final func start() {
        startCoordinator()
        afterStart()
    }

    func startCoordinator() {
        ConsoleLogger.warning("Method startCoordinator need override in \(self.description)")
    }

    private func afterStart() {
        if isAutoFinishEnabled {
            rootViewController?.didDismiss.emit(onNext: { [weak self] _ in
                self?.finish()
            })
            .disposed(by: disposeBag)
        }

        ConsoleLogger.log(
            "## Did Start: \(String(describing: self)) with \(self.rootViewController?.description ?? "rootViewController (nil)")"
        )
    }

    /// Этот метод вызывать не надо самому в большинстве случаев
    /// надо только если isAutoFinishEnabled == false
    func finish() {
        parent?.removeChild(self)
        ConsoleLogger.log("## Did Finish: \(self.description)")
    }

    // MARK: - Helpers

    func startChild(_ child: Coordinator) {
        addChild(child)
        child.start()
    }

}
