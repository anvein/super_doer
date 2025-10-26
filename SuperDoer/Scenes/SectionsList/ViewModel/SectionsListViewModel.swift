import Foundation
import RxSwift

final class SectionsListViewModel {

    typealias SectionGroup = [[TaskSectionProtocol]]

    private let disposeBag = DisposeBag()

    // MARK: - Services

    private weak var coordinator: (any SectionsListCoordinatorType)?
    private let sectionEm: TaskSectionEntityManager
    private let systemSectionsBuilder: SystemSectionsBuilder

    // MARK: - Model

    static var systemSectionsId = 0
    static var customSectionsId = 1

    private var sections: UIBox<SectionGroup> = .init(SectionGroup())
    private var selectedSectionIndexPath: IndexPath?

    // MARK: - Init

    required init(
        coordinator: any SectionsListCoordinatorType,
        sectionEm: TaskSectionEntityManager,
        systemSectionsBuilder: SystemSectionsBuilder
    ) {
        self.coordinator = coordinator
        self.sectionEm = sectionEm
        self.systemSectionsBuilder = systemSectionsBuilder

        self.sections = UIBox(SectionGroup())

        setupBindings()
    }

}

// MARK: - TaskSectionListViewModelType

extension SectionsListViewModel: SectionsListViewModelType {

    // MARK: - Observable

    var sectionsObservable: UIBoxObservable<Sections> { sections.asObservable() }

    // MARK: - Setup

    private func setupBindings() {
        coordinator?.viewModelEventSignal.emit(onNext: { [weak self] event in
            switch event {
            case .onDeleteSectionConfirmed(let deletableSections):
                self?.handleConfirmDelete(deletableSections)

            case .onDeleteSectionCanceled:
                return
            }
        })
        .disposed(by: disposeBag)
    }

    // MARK: - Get data

    func getCountOfTableSections() -> Int {
        return sections.value.count
    }

    func getCountTaskSectionsInTableSection(with sectionId: Int) -> Int {
        return sections.value[safe: sectionId]?.count ?? 0
    }

    func getTaskSectionTableCellVM(for indexPath: IndexPath) -> SectionListTableCellVMType? {
        let section = sections.value[safe: indexPath.section]?[safe: indexPath.row]

        switch section {
        case let taskSectionCustom as CDTaskCustomSection :
            return SectionCustomListTableCellVM(section: taskSectionCustom)

        case let taskSectionSystem as TaskSystemSection:
            return SectionSystemListTableCellVM(section: taskSectionSystem)

        default:
            return nil
        }
    }

//    func getTasksCountInSection(withSectionId id: Int) -> Int {
//        return Int.random(in: 0...11)
//    }

    // MARK: - UI Actions

    func loadInitialData() {
        var sections: [[TaskSectionProtocol]] = [[], []]

        sections[Self.systemSectionsId] = systemSectionsBuilder.buildSections()
        sections[Self.customSectionsId] = sectionEm.getCustomSectionsWithOrder()

        self.sections.value = sections
    }

    func didTapDeleteCustomSection(with indexPath: IndexPath) {
        guard let section = sections.value[safe: indexPath.section]?[safe: indexPath.row],
              let customSection = section as? CDTaskCustomSection else { return }

        coordinator?.startDeleteSectionConfirm(customSection, indexPath)
    }

    func didTapArchiveCustomSection(indexPath: IndexPath) {
        guard let section = sections.value[safe: Self.customSectionsId]?[safe: indexPath.row],
              let customSection = section as? CDTaskCustomSection else { return }

        sectionEm.updateCustomSectionField(isArchive: true, section: customSection)
        sections.value[Self.customSectionsId].remove(at: indexPath.item)
    }

    func didSelectTaskSection(with indexPath: IndexPath) {
        guard let section = sections.value[safe: indexPath.section]?[safe: indexPath.row] else { return }

        coordinator?.startTasksInSectionFlow(section)
    }

    func didConfirmCreateCustomSection(title: String) {
        let section = sectionEm.createCustomSectionWith(title: title)
        sections.value[Self.customSectionsId].insert(section, at: 0)
    }

    // MARK: model manipulate methods

    func createCustomSectionWith(title: String) {
        let section = sectionEm.createCustomSectionWith(title: title)
        sections.value[SectionsListViewModel.customSectionsId].insert(section, at: 0)
    }

    // MARK: - Actions handlers

    private func handleConfirmDelete(_ deletableViewModels: [TaskSectionDeletableViewModel]) {
        guard let deletableVM = deletableViewModels.first,
        let indexPath = deletableVM.indexPath,
        let section = sections.value[safe: Self.customSectionsId]?[safe: indexPath.row],
        let customSection = section as? CDTaskCustomSection
        else { return }

        sectionEm.deleteSection(customSection)
        sections.value[Self.customSectionsId].remove(at: indexPath.row)
    }

}

