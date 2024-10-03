
import Foundation

class UIBox<T> {
    typealias Listener = (T) -> ()
    
    private var listener: Listener?
    
    var value: T {
        didSet {
            Task { @MainActor in
                listener?(value)
            }
        }
    }
    
    init(_ value: T) {
        self.value = value
    }

    func setListener(_ listener: @escaping Listener) {
        self.listener = listener
    }

    func asObservable() -> UIBoxObservable<T> {
        return .init(uiBox: self)
    }

    func forceUpdate() {
        Task { @MainActor in
            listener?(value)
        }
    }

}
