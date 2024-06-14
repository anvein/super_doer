
import Foundation

class Box<T> {
    typealias Listener = (T) -> ()
    
    private var listener: Listener?
    
    var value: T {
        didSet {
            listener?(value)
        }
    }
    
    init(_ value: T) {
        self.value = value
    }
    
    func bind(listener: @escaping Listener) {
        self.listener = listener
    }
    
    func bindAndUpdateValue(listener: @escaping Listener) {
        self.listener = listener
        listener(value)
    }
    
    func forceUpdate() {
        listener?(value)
    }
    
}
