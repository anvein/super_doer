import Foundation
import RxCocoa
import RxRelay
import RxSwift
import OrderedCollections

final class SectionsListViewModel: SectionsListCoordinatorResultHandler, SectionsListNavigationEmittable,
    SectionsListViewModelInout {
    typealias DataViewModels = OrderedDictionary<SectionsListGroupViewModel, [TaskSectionCellViewModel]>

    let disposeBag = DisposeBag()

    // MARK: - Navigation

    var coordinatorResult = PublishRelay<SectionsListCoordinatorResult>()

    private let navigationEventRelay = PublishRelay<SectionsListNavigationEvent>()
    var navigationEvent: Signal<SectionsListNavigationEvent> { navigationEventRelay.asSignal() }

    // MARK: - Inout (properties)

    private let didUpdatedDataRelay = PublishRelay<DataViewModels>()
    var didUpdatedData: Signal<DataViewModels> { didUpdatedDataRelay.asSignal() }

    // MARK: - Services

    private let repository: TaskSectionRepository

    // MARK: - Model

    private var customSections: [CDTaskCustomSection] = []
    private var systemSections: [TaskSystemSection] = []

    // MARK: - Init

    required init(repository: TaskSectionRepository) {
        self.repository = repository
        setupBindings()
    }

    // MARK: - Inout (UI Actions)

    func loadInitialData() {
        systemSections = repository.getSystemSectionsList()
        customSections = repository.getActiveCustomSectionsListWithOrder()

        didUpdatedDataRelay.accept(buildDataViewModels())
    }

    func didTapDeleteCustomSection(with indexPath: IndexPath) {
        guard let section = customSections[safe: indexPath.row] else { return }

        let deletableSectionVM = TaskSectionDeletableViewModel(
            title: section.title ?? "",
            indexPath: indexPath
        )

        navigationEventRelay.accept(.openDeleteSectionConfirmation(deletableSectionVM))
    }

    func didTapArchiveCustomSection(with indexPath: IndexPath) {
        guard let section = customSections[safe: indexPath.row] else { return }

        repository.archiveCustomSection(section)
        customSections.remove(at: indexPath.row)

        didUpdatedDataRelay.accept(buildDataViewModels())
    }

    func didTapOpenTasksListInSection(with indexPath: IndexPath) {
        guard let sectionsGroup = SectionsListGroupViewModel(rawValue: indexPath.section) else { return }

        switch sectionsGroup {
        case .system:
            navigationEventRelay.accept(.openTasksListInSystemSection)

        case .custom:
            guard let section = customSections[safe: indexPath.row], let sectionId = section.id else { return }
            navigationEventRelay.accept(.openTasksListInCustomSection(id: sectionId))
        }
    }

    func didConfirmCreateCustomSection(title: String) {
        let section = repository.createCustomSection(title: title)
        customSections.insert(section, at: 0)

        didUpdatedDataRelay.accept(buildDataViewModels())
    }

    // MARK: - Setup

    private func setupBindings() {
        coordinatorResult.subscribe(onNext: { [weak self] event in
            switch event {
            case .onDeleteSectionConfirmed(let deletableSections):
                self?.handleConfirmDelete(deletableSections)

            case .onDeleteSectionCanceled:
                return
            }
        })
        .disposed(by: disposeBag)
    }

    // MARK: - Actions handlers

    private func handleConfirmDelete(_ deletableViewModels: [TaskSectionDeletableViewModel]) {
        guard let deletableVM = deletableViewModels.first,
            let indexPath = deletableVM.indexPath,
            let customSection = customSections[safe: indexPath.row]
        else { return }

        repository.deleteCustomSection(customSection)
        customSections.remove(at: indexPath.row)

        didUpdatedDataRelay.accept(buildDataViewModels())
    }

    // MARK: - Helpers

    private func buildDataViewModels() -> DataViewModels {
        return [
            .system: systemSections.map { .build(from: $0) },
            .custom: customSections.map { .build(from: $0) },
        ]
    }

}
