import UIKit

class PIXEL_PERFECT_screen {

    // MARK: - Settings

    private var imageName: String

    /// К какой стороне крепить изображение
    private var imageAnchorSide: PPImageAttachVerticalSide

    /// Отступ для изображения от выбранного imageAnchorSide (.topAnchor / .bottomAnchor)
    private var imageAnchorSideConstant: Float

    /// Отступ для контролов от bottomAnchor
    private var controlsBottomAnchorConstant: Float {
        didSet {
            sliderBottomConstraint?.constant = CGFloat(controlsBottomAnchorConstant)
            switchBottomConstraint?.constant = CGFloat(controlsBottomAnchorConstant)
        }
    }

    /// Какой Scale у изображения
    /// (на сколько делить по высоте картинку для выставления размера)
    private var heightDivider: Float

    // MARK: - Constraints

    private var screenRightConstraint: NSLayoutConstraint?
    private var sliderBottomConstraint: NSLayoutConstraint?
    private var switchBottomConstraint: NSLayoutConstraint?

    // MARK: - State

    private var isViewScreen = false

    // MARK: - Views

    private lazy var screenIsVisibleSwitch = UISwitch()
    private lazy var screenImageView = UIImageView()
    private lazy var sliders: [PPSlider] = []

    // MARK: - Other properties

    /// Вьюха на которую будет добавляться  PIXEL_PERFECT_screen
    private weak var baseView: UIView?

    /// Просто хранилище инстансов, чтобы не надо было их хранить в свойствах (т.к. тут сильные ссылки)
    private static var instances: [String: PIXEL_PERFECT_screen] = [:]

    private static var lastInstanceKey: String?

    /// Настройки слайдеров для следующего инстанса PIXEL_PERFECT_screen
    private static var slidersConfigsForNext: [PPSliderConfig] = []

    private var lastSliderValue: Float = 0

    // MARK: - Init

    private init(
        baseView: UIView,
        imageName: String,
        imageAttachSide: PPImageAttachVerticalSide,
        imageAttachSideOffset: Float,
        controlsBottomSideOffset: Float,
        imageHeightDivider: Float
    ) {
        self.baseView = baseView
        self.imageName = imageName
        self.imageAnchorSide = imageAttachSide
        self.imageAnchorSideConstant = imageAttachSideOffset
        self.controlsBottomAnchorConstant = controlsBottomSideOffset
        self.heightDivider = imageHeightDivider
    }

    deinit {
        Self.printMessage(prefix: "💡🗑️", "Удален скрин \(imageName)")
    }

    // MARK: - External setup

    @discardableResult
    static func createAndSetupInstance(
        baseView: UIView,
        imageName: String = "PIXEL_PERFECT_image",
        imageAttachSide: PPImageAttachVerticalSide = .top,
        imageAttachSideOffset: Float = 0,
        controlsBottomSideOffset: Float = 0,
        imageHeightDivider: Float = 3
    ) -> PIXEL_PERFECT_screen {
        let instance = PIXEL_PERFECT_screen(
            baseView: baseView,
            imageName: imageName,
            imageAttachSide: imageAttachSide,
            imageAttachSideOffset: imageAttachSideOffset,
            controlsBottomSideOffset: controlsBottomSideOffset,
            imageHeightDivider: imageHeightDivider
        )
        instance.setup()
        PIXEL_PERFECT_screen.slidersConfigsForNext = []
        PIXEL_PERFECT_screen.instances[imageName] = instance
        PIXEL_PERFECT_screen.lastInstanceKey = imageName

        Self.printMessage(prefix: "💡🌆", "Добавлен новый скрин \(imageName)")

        return instance
    }

    static func addSliderForNextInstance(_ config: PPSliderConfig) {
        PIXEL_PERFECT_screen.slidersConfigsForNext.append(config)
        Self.printMessage(prefix: "💡🎚️", "добавлен новый слайдер \(config.title ?? "<без имени>")")
    }

    static func addSliderForLastInstance(_ config: PPSliderConfig) {
        guard let lastInstanceKey = self.lastInstanceKey else {
            Self.printError("lastInstanceKey пуст - слайдер \(config.title ?? "<без названия>") не добавлен")
            return
        }

        guard let lastInstance = instances[lastInstanceKey] else {
            Self.printError("lastInstance с ключом \(lastInstanceKey) не найден - слайдер \(config.title ?? "<без названия>") не добавлен")
            return
        }

        lastInstance.addSlider(config)
        Self.printMessage(prefix: "💡🎚️", "Добавлен новый слайдер \(config.title ?? "<без имени>") в \(lastInstance.imageName)")
    }

}

private extension PIXEL_PERFECT_screen {

    // MARK: - Internal setup

    func setup() {
        setupControls()
        addSubviewsAndSetupConstraints()
        setScreenIsVisible(false)
    }

    func setupControls() {
        // screenImageView
        screenImageView.translatesAutoresizingMaskIntoConstraints = false
        screenImageView.tag = 777
        screenImageView.isUserInteractionEnabled = true
        screenImageView.layer.zPosition = 99998 /*+ Self.instances.count.cgFloat * 2*/
        if let image = UIImage(named: imageName) {
            screenImageView.image = image
        } else {
            Self.printError("Изображение \(imageName) невозможно получить")
        }

        let screenSwipeUpGR = UISwipeGestureRecognizer(target: self, action: #selector(self.imageSwipeHandler(_:)))
        screenSwipeUpGR.direction = .up
        screenImageView.addGestureRecognizer(screenSwipeUpGR)

        let screenSwipeDownGR = UISwipeGestureRecognizer(target: self, action: #selector(self.imageSwipeHandler(_:)))
        screenSwipeDownGR.direction = .down
        screenImageView.addGestureRecognizer(screenSwipeDownGR)

        let imageViewDoubleTapGR = UITapGestureRecognizer(target: self, action: #selector(imageDoubleTabHandler(_:)))
        imageViewDoubleTapGR.numberOfTapsRequired = 2
        screenImageView.addGestureRecognizer(imageViewDoubleTapGR)

        // screenIsVisibleSwitch
        screenIsVisibleSwitch.translatesAutoresizingMaskIntoConstraints = false
        screenIsVisibleSwitch.isOn = false
        screenIsVisibleSwitch.onTintColor = .systemOrange
        screenIsVisibleSwitch.thumbTintColor = .systemBlue
        screenIsVisibleSwitch.layer.zPosition = 99999 /*+ Self.instances.count.cgFloat * 2*/
        screenIsVisibleSwitch.isHidden = false

        screenIsVisibleSwitch.addTarget(self, action: #selector(screenIsVisibleSwitchValueChange(tdSwitch: event:)), for: .valueChanged)

        // sliders
        PIXEL_PERFECT_screen.slidersConfigsForNext.forEach { [weak self] config in
            let slider = self?.buildSliderFromConfig(config)

            if let slider {
                slider.addTarget(self, action: #selector(self?.sliderDoubleTap(slider:)), for: .touchDownRepeat)

                slider.addAction(UIAction(handler: { [weak self] action in
                    guard let slider = action.sender as? PPSlider else { return }
                    self?.sliderValueChanged(slider: slider, handler: config.handler)
                }), for: .valueChanged)

                self?.sliders.append(slider)
            } else {
                Self.printError("Слайдер \(config.title ?? "<без имени>") не будет добавлен")
            }
        }
    }

    func addSubviewsAndSetupConstraints() {
        guard let baseView else {
            Self.printError("недоступно baseView")
            return
        }

        // screenIsVisibleSwitch
        baseView.addSubview(screenIsVisibleSwitch)

        let switchBottomConstraint =  screenIsVisibleSwitch.bottomAnchor.constraint(
            equalTo: baseView.safeAreaLayoutGuide.bottomAnchor,
            constant: CGFloat(controlsBottomAnchorConstant)
        )

        NSLayoutConstraint.activate([
            screenIsVisibleSwitch.leftAnchor.constraint(equalTo: baseView.leftAnchor, constant: 20),
            switchBottomConstraint
        ])
        self.switchBottomConstraint = switchBottomConstraint

        // slider's
        var prevSlider: UISlider?
        sliders.forEach { slider in
            baseView.addSubview(slider)

            let bottomConstraint: NSLayoutConstraint
            if let prevSlider {
                bottomConstraint = slider.bottomAnchor.constraint(equalTo: prevSlider.topAnchor)
            } else {
                bottomConstraint = slider.bottomAnchor.constraint(
                    equalTo: baseView.safeAreaLayoutGuide.bottomAnchor,
                    constant: CGFloat(controlsBottomAnchorConstant)
                )
                sliderBottomConstraint = bottomConstraint
            }

            NSLayoutConstraint.activate([
                slider.leftAnchor.constraint(equalTo: screenIsVisibleSwitch.rightAnchor, constant: 20),
                slider.rightAnchor.constraint(equalTo: baseView.safeAreaLayoutGuide.rightAnchor, constant: -20),
                bottomConstraint
            ])

           prevSlider = slider
        }
    }

    func addSlider(_ config: PPSliderConfig) {
        guard let baseView else {
            Self.printError("Недоступно baseView")
            return
        }

        let slider = buildSliderFromConfig(config)

        baseView.addSubview(slider)

        let bottomConstraint: NSLayoutConstraint
        let lastSlider = sliders.last

        if let lastSlider {
            bottomConstraint = slider.bottomAnchor.constraint(equalTo: lastSlider.topAnchor)
        } else {
            bottomConstraint = slider.bottomAnchor.constraint(
                equalTo: baseView.safeAreaLayoutGuide.bottomAnchor,
                constant: CGFloat(controlsBottomAnchorConstant)
            )
            sliderBottomConstraint = bottomConstraint
        }

        NSLayoutConstraint.activate([
            slider.leftAnchor.constraint(equalTo: screenIsVisibleSwitch.rightAnchor, constant: 20),
            slider.rightAnchor.constraint(equalTo: baseView.safeAreaLayoutGuide.rightAnchor, constant: -20),
            bottomConstraint
        ])

        slider.addTarget(self, action: #selector(sliderDoubleTap(slider:)), for: .touchDownRepeat)

        slider.addAction(UIAction(handler: { [weak self] action in
            guard let slider = action.sender as? PPSlider else { return }
            self?.sliderValueChanged(slider: slider, handler: config.handler)
        }), for: .valueChanged)

        sliders.append(slider)
    }

    // MARK: - Update view

    func setScreenIsVisible(_ isViewScreen: Bool) {
        guard let baseView else {
            Self.printError("Недоступно baseView")
            return
        }

        guard let screenImage = screenImageView.image else {
            Self.printError("Недоступно screenImageView.image")
            return
        }

        let imageView = baseView.viewWithTag(777)
        if imageView == nil {
            baseView.addSubview(screenImageView)
            baseView.bringSubviewToFront(screenIsVisibleSwitch)
            sliders.forEach { slider in
                baseView.bringSubviewToFront(slider)
            }

            let rightConstraint = screenImageView.rightAnchor.constraint(equalTo: baseView.rightAnchor)
            screenRightConstraint = rightConstraint

            let topOrBottomAnchorConstraint: NSLayoutConstraint
            if imageAnchorSide == .top {
                topOrBottomAnchorConstraint = screenImageView.topAnchor.constraint(
                    equalTo: baseView.topAnchor,
                    constant: CGFloat(imageAnchorSideConstant)
                )
            } else {
                topOrBottomAnchorConstraint = screenImageView.bottomAnchor.constraint(
                    equalTo: baseView.bottomAnchor,
                    constant: CGFloat(imageAnchorSideConstant)
                )
            }

            NSLayoutConstraint.activate([
                topOrBottomAnchorConstraint,
                screenImageView.leftAnchor.constraint(equalTo: baseView.leftAnchor),
                rightConstraint,
                screenImageView.heightAnchor.constraint(equalToConstant: screenImage.size.height / CGFloat(heightDivider))
            ])
        }

        screenImageView.alpha = isViewScreen ? 1 : screenImageView.alpha
        screenImageView.isHidden = !isViewScreen

//        screenRightConstraint?.constant = isViewScreen ? 0 : -baseView.frame.width
        screenImageView.layer.zPosition = 99998/* + Self.instances.count.cgFloat * 2*/

        sliders.forEach { slider in
            slider.isHidden = false
        }
    }

    // MARK: - Helpers

    func buildSliderFromConfig(_ config: PPSliderConfig) -> PPSlider {
        let slider = PPSlider()
        slider.title = config.title
        slider.translatesAutoresizingMaskIntoConstraints = false
        slider.layer.zPosition = 99999/* + Self.instances.count.cgFloat * 2*/
        slider.isHidden = false

        slider.minimumValue = config.minValue
        slider.maximumValue = config.maxValue
        slider.value = config.initialValue

        return slider
    }

    // MARK: - Actions handlers

    @objc func screenIsVisibleSwitchValueChange(tdSwitch: UISwitch, event: UIEvent) {
        setScreenIsVisible(tdSwitch.isOn)
    }

    @objc func sliderValueChanged(slider: PPSlider, handler: PPSliderConfig.SliderChangeValueHandler) {
        let newValue = round(slider.value)
        slider.setValue(newValue, animated: false)

        guard newValue != lastSliderValue else { return }

        slider.labelValue = newValue
        handler(newValue)
        lastSliderValue = newValue
    }

    @objc func sliderDoubleTap(slider: PPSlider) {
        slider.isHidden = !slider.isHidden
    }

    @objc func imageSwipeHandler(_ gestureRecognizer: UISwipeGestureRecognizer) {
        guard gestureRecognizer.state == .ended else { return }

        if gestureRecognizer.direction == .up && screenImageView.alpha < 1 {
            let newValue = screenImageView.alpha + 0.3
            screenImageView.alpha = newValue >= 1 ? 1 : newValue
        } else if gestureRecognizer.direction == .down && screenImageView.alpha > 0 {
            let newValue = screenImageView.alpha - 0.3
            screenImageView.alpha = newValue <= 0 ? 0.05 : newValue
        }
    }

    @objc func imageDoubleTabHandler(_ gestureRecognizer: UITapGestureRecognizer) {
        guard gestureRecognizer.state == .ended else { return }

        guard let imageView = gestureRecognizer.view as? UIImageView else { return }
        let point = gestureRecognizer.location(in: imageView)

        if point.y > (imageView.frame.height / 2) {
            controlsBottomAnchorConstant += 30
        } else {
            controlsBottomAnchorConstant -= 30
        }
    }

    // MARK: - Helpers: printing

    static func printError(_ text: String) {
        Self.printMessage(prefix: "❌ ❌ ❌", text)
    }

    static func printMessage(prefix: String, _ text: String) {
        print("\(prefix) PIXEL PERFECT SCREEN: \(text)")
    }
}

extension PIXEL_PERFECT_screen {

    // MARK: - Internal Code-entities

    fileprivate class PPSlider: UISlider {
        var title: String?
        var labelValue: Float = 0 {
            didSet {
                var titleString: String = ""
                if let title {
                    titleString = "\(title): "
                }

                label.text = "\(titleString)\(Int(labelValue))"
            }
        }

        private lazy var label: UILabel = {
            $0.translatesAutoresizingMaskIntoConstraints = false
            $0.textColor = .white
            $0.shadowColor = .black
            $0.shadowOffset = .init(width: -1, height: 1)
            $0.layer.shadowOpacity = 1
            $0.layer.shadowRadius = 2
            $0.font = .systemFont(ofSize: 12)
            return $0
        }(UILabel())

        convenience init() {
            self.init(frame: .zero)

            addSubview(label)
            NSLayoutConstraint.activate([
                label.trailingAnchor.constraint(equalTo: self.trailingAnchor, constant: 10),
                label.bottomAnchor.constraint(equalTo: self.centerYAnchor, constant: 5)
            ])
        }
    }

    struct PPSliderConfig {
        typealias SliderChangeValueHandler = (Float) -> Void

        var title: String?
        var initialValue: Float
        var minValue: Float
        var maxValue: Float
        var handler: SliderChangeValueHandler
    }

    enum PPImageAttachVerticalSide {
        case top
        case bottom
    }
}
