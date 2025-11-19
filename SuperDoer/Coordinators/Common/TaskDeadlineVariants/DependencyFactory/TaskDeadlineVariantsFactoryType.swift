import Foundation

protocol TaskDeadlineVariantsFactoryType {
    func makeDependency(value: Date?) -> TaskDeadlineVariantsDependency
}
