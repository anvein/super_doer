import Swinject
import Foundation

// swiftlint:disable force_unwrapping
final class TaskRepeatPeriodVariantsFactory {

    private let resolver: Resolver

    init(resolver: Resolver) {
        self.resolver = resolver
    }

    func makeDependency(value: TaskRepeatPeriod?) -> TaskRepeatPeriodVariantsDependency<TaskRepeatPeriod> {
        let vm = TableVariantsViewModel(
            value: value,
            variantsFactory: resolver.resolve(TaskRepeatPeriodVariantsItemsFactory.self)!,
            selectedVariantFinder: resolver.resolve(TaskRepeatPeriodTableVariantFinder.self)!
        )
        let anyVM = AnyTableVariantsNavigationEmittable(vm)

        let vc = TableVariantsViewController(
            viewModel: vm,
            detent: .taskRepeatPeriodVariants,
            title: "Повтор"
        )

        return .init(viewModel: anyVM, viewController: vc)
    }

}
// swiftlint:enable force_unwrapping
