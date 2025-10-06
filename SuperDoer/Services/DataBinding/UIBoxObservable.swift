
class UIBoxObservable<T> {

    private let uiBox: UIBox<T>

    init(uiBox: UIBox<T>) {
        self.uiBox = uiBox
    }

    func bind(listener: @escaping UIBox<T>.Listener) {
        uiBox.setListener(listener)
    }

    func bindAndUpdateValue(listener: @escaping UIBox<T>.Listener) {
        uiBox.setListener(listener)
        forceUpdate()
    }

    func forceUpdate() {
        uiBox.forceUpdate()
    }

}

