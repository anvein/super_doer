import Swinject
import Foundation

// swiftlint:disable force_unwrapping
final class TaskDeadlineVariantsFactory: TaskDeadlineVariantsFactoryType {

    private let resolver: Resolver

    init(resolver: Resolver) {
        self.resolver = resolver
    }

    func makeDependency(value: Date?) -> TaskDeadlineVariantsDependency {
        let vm = TableVariantsViewModel(
            value: value,
            variantsFactory: resolver.resolve(TaskDeadlineVariantsItemsFactory.self)!,
            selectedVariantFinder: resolver.resolve(TaskDeadlineTableVariantFinder.self)!
        )
        let anyViewModel = AnyTableVariantsNavigationEmittable(vm)
        let vc = TableVariantsViewController(
            viewModel: vm,
            detent: .taskDeadlineVariants,
            title: "Срок"
        )

        return .init(viewModel: anyViewModel, viewController: vc)
    }

}
// swiftlint:enable force_unwrapping
