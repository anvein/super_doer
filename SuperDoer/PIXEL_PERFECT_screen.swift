import UIKit
import Foundation

// swiftlint:disable all
class PIXEL_PERFECT_screen {

    // MARK: - Services

    private lazy var userDefaults: UserDefaults? = .init(suiteName: "com.nova.pixelperfect")

    // MARK: - Settings

    private var imageName: String

    /// Какой Scale у изображения относительно логического разрешения экрана
    private var imageScaleFactor: Float

    // MARK: - Constraints

    private var screenTopConstraint: NSLayoutConstraint?
    private var screenLeadingConstraint: NSLayoutConstraint?
    private var screenWidthConstraint: NSLayoutConstraint?

    private var controlsBottomConstraint: NSLayoutConstraint?

    // MARK: - State

    private var isVisibleImage = false
    private var isVisibleLinesSpacings = false
    private var isVisibleSliders = true

    /// Отступ для контролов от bottomAnchor
    private var controlsBottomAnchorConstant: Float {
        didSet {
            controlsBottomConstraint?.constant = CGFloat(controlsBottomAnchorConstant)
        }
    }

    // MARK: - Subviews

    private lazy var isVisibleScreenSwitch: UISwitch = {
        $0.translatesAutoresizingMaskIntoConstraints = false
        $0.isOn = false
        $0.onTintColor = .systemOrange
        $0.thumbTintColor = .systemBlue
        $0.layer.zPosition = PPZPosition.control.asCgFloat
        return $0
    }(UISwitch())

    private lazy var actionsMenuButton: UIButton = {
        $0.translatesAutoresizingMaskIntoConstraints = false
        $0.layer.zPosition = PPZPosition.control.asCgFloat
        $0.backgroundColor = .systemBlue
        $0.tintColor = .white
        $0.layer.cornerRadius = PPConstants.menuButtonSize / 2
        $0.setImage(UIImage(systemName: "plus"), for: .normal)
        $0.showsMenuAsPrimaryAction = true
        $0.menu = buildActionsMenu()
        return $0
    }(UIButton())

    private lazy var sliders: [PPSlider] = []

    private lazy var horizontalLines: [PPHorizontalLineView] = []
    private lazy var verticalLines: [PPVerticalLineView] = []

    private lazy var horizontalLinesSpacings: [PPHorizontalLineSpacing] = []
    private lazy var verticalLinesSpacings: [PPVerticalLineSpacing] = []

    private lazy var screenImageView: UIImageView = {
        $0.translatesAutoresizingMaskIntoConstraints = false
        $0.tag = PPConstants.screenImageViewTag
        $0.isUserInteractionEnabled = true
        $0.layer.zPosition = PPZPosition.image.asCgFloat

        return $0
    }(UIImageView())

    // MARK: - Other properties

    /// Вьюха на которую будет добавляться  PIXEL_PERFECT_screen
    private weak var baseView: UIView?

    /// Просто хранилище инстансов, чтобы не надо было их хранить в свойствах контроллера (т.к. тут сильные ссылки)
    private static var instances: [String: PIXEL_PERFECT_screen] = [:]

    private static var lastInstanceKey: String?

    /// Настройки слайдеров для следующего инстанса PIXEL_PERFECT_screen
    private static var slidersConfigsForNext: [PPSliderConfig] = []

    /// Свойство для временного хранения посленднего значения последнего измененного слайдера
    private var lastSliderValue: Float = 0

    // MARK: - Init

    private init(
        baseView: UIView,
        imageName: String,
        controlsBottomSideOffset: Float,
        imageScaleFactor: Float
    ) {
        self.baseView = baseView
        self.imageName = imageName
        self.controlsBottomAnchorConstant = controlsBottomSideOffset
        self.imageScaleFactor = imageScaleFactor

        setupMain()
    }

    deinit {
        Self.printMessage(prefix: "💡🗑️", "Удален скрин \(imageName)")
    }

    // MARK: - External setup

    @discardableResult
    static func createAndSetupInstance(
        baseView: UIView,
        imageName: String = "PIXEL_PERFECT_image",
        controlsBottomSideOffset: Float = 0,
        imageScaleFactor: Float = 3
    ) -> PIXEL_PERFECT_screen {
        let instance = PIXEL_PERFECT_screen(
            baseView: baseView,
            imageName: imageName,
            controlsBottomSideOffset: controlsBottomSideOffset,
            imageScaleFactor: imageScaleFactor
        )
        PIXEL_PERFECT_screen.slidersConfigsForNext = []
        PIXEL_PERFECT_screen.instances[imageName] = instance
        PIXEL_PERFECT_screen.lastInstanceKey = imageName

        Self.printMessage(prefix: "💡🌆", "Добавлен новый скрин \(imageName)")

        return instance
    }

    static func addSliderForNextInstance(_ config: PPSliderConfig) {
        PIXEL_PERFECT_screen.slidersConfigsForNext.append(config)
        Self.printMessage(prefix: "💡🎚️", "добавлен новый слайдер \(config.titleForPrint)")
    }

    static func addSliderForLastInstance(_ config: PPSliderConfig) {
        guard let lastInstanceKey = self.lastInstanceKey else {
            Self.printError("lastInstanceKey пуст - слайдер \(config.titleForPrint) не добавлен")
            return
        }

        guard let lastInstance = instances[lastInstanceKey] else {
            Self.printError("lastInstance с ключом \(lastInstanceKey) не найден - слайдер \(config.titleForPrint) не добавлен")
            return
        }

        lastInstance.addSlider(config)
        Self.printMessage(prefix: "💡🎚️", "Добавлен новый слайдер \(config.titleForPrint) в \(lastInstance.imageName)")
    }

}

private extension PIXEL_PERFECT_screen {

    // MARK: - Internal setup

    func setupMain() {
        setupControls()
        addSubviewsAndSetupConstraints()
        createSlidersFromConfigsForNextInstance()
        setupNotifications()
        setScreenIsVisible(false)
    }

    func setupControls() {
        // screenImageView
        if let image = UIImage(named: imageName) {
            screenImageView.image = image
        } else {
            Self.printError("Изображение \(imageName) невозможно получить")
        }

        screenImageView.addGestureRecognizer(
            UIPanGestureRecognizer(target: self, action: #selector(imagePanGestureHandler(_:)))
        )

        // screenIsVisibleSwitch
        isVisibleScreenSwitch.addTarget(self, action: #selector(screenIsVisibleSwitchValueChange(tdSwitch: event:)), for: .valueChanged)

        // menuButton
        addControlsMovePanGestureRecognizerTo(view: actionsMenuButton)
    }

    func setupNotifications() {
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(updateMenuForActionsMenuButton),
            name: PPNotifications.actionsMenuStateUpdated,
            object: nil
        )
    }

    func addSubviewsAndSetupConstraints() {
        guard let baseView else {
            Self.printError("недоступно baseView")
            return
        }

        // screenIsVisibleSwitch
        baseView.addSubview(isVisibleScreenSwitch)

        let switchBottomConstraint = isVisibleScreenSwitch.bottomAnchor.constraint(
            equalTo: baseView.safeAreaLayoutGuide.bottomAnchor,
            constant: CGFloat(PPConstants.defaultControlsBottomPadding)
        )

        NSLayoutConstraint.activate([
            isVisibleScreenSwitch.leftAnchor.constraint(equalTo: baseView.leftAnchor, constant: 20),
            switchBottomConstraint
        ])
        self.controlsBottomConstraint = switchBottomConstraint

        // menuButton
        baseView.addSubview(actionsMenuButton)

        NSLayoutConstraint.activate([
            actionsMenuButton.leadingAnchor.constraint(equalTo: isVisibleScreenSwitch.leadingAnchor),
            actionsMenuButton.bottomAnchor.constraint(equalTo: isVisibleScreenSwitch.topAnchor, constant: -10),
            actionsMenuButton.heightAnchor.constraint(equalToConstant: PPConstants.menuButtonSize),
            actionsMenuButton.widthAnchor.constraint(equalToConstant: PPConstants.menuButtonSize),
        ])
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

        let imageView = baseView.viewWithTag(PPConstants.screenImageViewTag)
        if imageView == nil {
            baseView.addSubview(screenImageView)

            baseView.bringSubviewToFront(isVisibleScreenSwitch)
            baseView.bringSubviewToFront(actionsMenuButton)

            sliders.forEach { slider in
                baseView.bringSubviewToFront(slider)
            }

            horizontalLines.forEach { line in
                baseView.bringSubviewToFront(line)
            }
            verticalLines.forEach { line in
                baseView.bringSubviewToFront(line)
            }
            horizontalLinesSpacings.forEach { lineSpacing in
                baseView.bringSubviewToFront(lineSpacing)
            }
            verticalLinesSpacings.forEach { lineSpacing in
                baseView.bringSubviewToFront(lineSpacing)
            }

            // screenImageView
            let imageTopOffset = getImageTopOffsetValueFromUD()
            let topAnchorConstraint = screenImageView.topAnchor.constraint(
                equalTo: baseView.topAnchor,
                constant: CGFloat(imageTopOffset)
            )
            self.screenTopConstraint = topAnchorConstraint

            let imageLeadingOffset = getImageLeadingOffsetValueFromUD()
            let leadingAnchorConstraint = screenImageView.leadingAnchor.constraint(
                equalTo: baseView.leadingAnchor,
                constant: CGFloat(imageLeadingOffset)
            )
            self.screenLeadingConstraint = leadingAnchorConstraint

            let imageWidthConstraint = screenImageView.widthAnchor.constraint(
                equalToConstant:  screenImage.size.width / CGFloat(imageScaleFactor)
            )
            self.screenWidthConstraint = imageWidthConstraint

            NSLayoutConstraint.activate([
                topAnchorConstraint,
                leadingAnchorConstraint,
                imageWidthConstraint,
                screenImageView.heightAnchor.constraint(
                    equalToConstant: screenImage.size.height / CGFloat(imageScaleFactor)
                ),
            ])
        }

        let imageRealWidth = screenImage.size.width / CGFloat(imageScaleFactor)
        screenWidthConstraint?.constant = isViewScreen ? imageRealWidth : 0

        screenImageView.alpha = isViewScreen ? 1 : screenImageView.alpha
        screenImageView.isHidden = !isViewScreen
        screenImageView.layer.zPosition = PPZPosition.image.asCgFloat
    }

    // MARK: - Sliders functions

    func createSlidersFromConfigsForNextInstance() {
        for config in PIXEL_PERFECT_screen.slidersConfigsForNext {
            addSlider(config)
        }
    }

    func addSlider(_ config: PPSliderConfig) {
        guard let baseView else {
            Self.printError("Недоступно baseView - слайдер \(config.titleForPrint) не будет добавлен")
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
                equalTo: isVisibleScreenSwitch.bottomAnchor
            )
        }

        NSLayoutConstraint.activate([
            slider.leftAnchor.constraint(equalTo: isVisibleScreenSwitch.rightAnchor, constant: 20),
            slider.rightAnchor.constraint(equalTo: baseView.safeAreaLayoutGuide.rightAnchor, constant: -20),
            bottomConstraint
        ])

        slider.addTarget(self, action: #selector(sliderDoubleTap(slider:)), for: .touchDownRepeat)
        slider.addTarget(
            self,
            action: #selector(sliderDidEndChangeValue(slider:)),
            for: [.touchUpInside, .touchUpOutside]
        )

        slider.addAction(UIAction(handler: { [weak self] action in
            guard let slider = action.sender as? PPSlider else { return }
            self?.sliderValueChanged(slider: slider, handler: config.handler)
        }), for: .valueChanged)

        addControlsMovePanGestureRecognizerTo(view: slider)

        sliders.append(slider)
    }

    func buildSliderFromConfig(_ config: PPSliderConfig) -> PPSlider {
        let slider = PPSlider(config: config)
        slider.title = config.title

        let values = calculateValuesForSlider(config: config)

        slider.minimumValue = values.min
        slider.maximumValue = values.max
        slider.value = values.current

        return slider
    }

    // MARK: - Lines (horizontal / vertical) functions

    func addVerticalLine() {
        guard let baseView else {
            Self.printError("Недоступно baseView - не удалось добавить Vertical line")
            return
        }

        let lineView = PPVerticalLineView()
        baseView.addSubview(lineView)
        lineView.translatesAutoresizingMaskIntoConstraints = false

        let leadingAnchorToLineConstraint = lineView.lineView.leadingAnchor.constraint(
            equalTo: baseView.leadingAnchor,
            constant: actionsMenuButton.frame.origin.x + actionsMenuButton.bounds.width + 30
        )
        NSLayoutConstraint.activate([
            leadingAnchorToLineConstraint,
            lineView.topAnchor.constraint(equalTo: baseView.topAnchor),
            lineView.bottomAnchor.constraint(equalTo: baseView.bottomAnchor),
            lineView.widthAnchor.constraint(equalToConstant: 15),
        ])
        lineView.leadingAnchorLineConstraint = leadingAnchorToLineConstraint
        lineView.addInfoLabelTrailingConstraintRelatively(baseView: baseView)

        lineView.removeLineClosure = { [weak self] lineView in
            guard let safeVerticalLines = self?.verticalLines else { return }

            self?.verticalLines = safeVerticalLines.filter({ view in
                view != lineView
            })

            lineView.removeFromSuperview()
            self?.reloadLinesSpacings(forceRebuildVertical: true)
        }

        lineView.moveLineClosure = { [weak self] in
            self?.reloadLinesSpacings()
        }

        verticalLines.append(lineView)
        reloadLinesSpacings()
    }

    func addHorizontalLine() {
        guard let baseView else {
            Self.printError("Недоступно baseView - не удалось добавить Horizontal line")
            return
        }

        let lineView = PPHorizontalLineView()
        baseView.addSubview(lineView)

        let topAnchorLineConstraint = lineView.lineView.topAnchor.constraint(
            equalTo: baseView.topAnchor,
            constant: actionsMenuButton.frame.origin.y - 30
        )
        NSLayoutConstraint.activate([
            topAnchorLineConstraint,
            lineView.leadingAnchor.constraint(equalTo: baseView.leadingAnchor),
            lineView.trailingAnchor.constraint(equalTo: baseView.trailingAnchor),
            lineView.heightAnchor.constraint(equalToConstant: 15),
        ])
        lineView.addInfoLabelBottomConstraintRelatively(baseView: baseView)
        lineView.topAnchorLineConstraint = topAnchorLineConstraint
        lineView.removeLineClosure = { [weak self] lineView in
            guard let safeHorizontalLines = self?.horizontalLines else { return }

            self?.horizontalLines = safeHorizontalLines.filter({ view in
                view != lineView
            })

            lineView.removeFromSuperview()
            self?.reloadLinesSpacings(forceRebuildHorizontal: true)
        }

        lineView.moveLineClosure = { [weak self] in
            self?.reloadLinesSpacings()
        }

        horizontalLines.append(lineView)
        reloadLinesSpacings(forceRebuildHorizontal: true)
    }

    // MARK: - Lines Spacing functions

    func switchIsVisibleLinesSpacings() {
        isVisibleLinesSpacings = !isVisibleLinesSpacings

        reloadLinesSpacings(forceRebuildHorizontal: true, forceRebuildVertical: true)
    }

    func reloadLinesSpacings(
        forceRebuildHorizontal: Bool = false,
        forceRebuildVertical: Bool = false
    ) {
        if isVisibleLinesSpacings {
            let isChangeOrderHorizontalLines = sortHorizontalLines()
            if isChangeOrderHorizontalLines || forceRebuildHorizontal {
                clearHorizontalLinesSpacings()
                createHorizontalLinesSpacings()
            } else {
                updateHorizontalLinesSpacingsInfo()
            }

            let isChangeOrderVerticalLines = sortVerticalLines()
            if isChangeOrderVerticalLines || forceRebuildVertical {
                clearVerticalLinesSpacings()
                createVerticalLinesSpacings()
            } else {
                updateVerticalLinesSpacingsInfo()
            }

        } else {
            clearHorizontalLinesSpacings()
            clearVerticalLinesSpacings()
        }
    }

    func clearHorizontalLinesSpacings() {
        horizontalLinesSpacings.forEach { lineSpacing in
            lineSpacing.removeFromSuperview()

            if let externalLayoutGuide = lineSpacing.externalLayoutGuide {
                baseView?.removeLayoutGuide(externalLayoutGuide)
            }
        }
        horizontalLinesSpacings = []
    }

    func clearVerticalLinesSpacings() {
        verticalLinesSpacings.forEach { lineSpacing in
            lineSpacing.removeFromSuperview()

            if let externalLayoutGuide = lineSpacing.externalLayoutGuide {
                baseView?.removeLayoutGuide(externalLayoutGuide)
            }
        }
        verticalLinesSpacings = []
    }

    @discardableResult
    func sortHorizontalLines() -> Bool {
        let sortedHorizontalLines = horizontalLines.sorted { lineView1, lineView2 in
            guard let lineView1TopConstant = lineView1.topAnchorLineConstraint?.constant,
                  let lineView2TopConstant = lineView2.topAnchorLineConstraint?.constant
            else { return false }

            return lineView1TopConstant < lineView2TopConstant
        }

        let isChangeOrderOfLines = sortedHorizontalLines != horizontalLines
        horizontalLines = sortedHorizontalLines

        return isChangeOrderOfLines
    }

    @discardableResult
    func sortVerticalLines() -> Bool {
        let sortedVerticalLines = verticalLines.sorted { lineView1, lineView2 in
            guard let lineView1LeadingConstant = lineView1.leadingAnchorLineConstraint?.constant,
                  let lineView2LeadingConstant = lineView2.leadingAnchorLineConstraint?.constant
            else { return false }

            return lineView1LeadingConstant < lineView2LeadingConstant
        }

        let isChangeOrderOfLines = sortedVerticalLines != verticalLines
        verticalLines = sortedVerticalLines

        return isChangeOrderOfLines
    }

    func createHorizontalLinesSpacings() {
        guard let baseView else {
            Self.printError("Недоступно baseView - не удалось добавить Horizontal Lines Spacings")
            return
        }

        var spacingLine: PPHorizontalLineSpacing
        var prevLineAnchorY: NSLayoutYAxisAnchor
        var nextAnchorY: NSLayoutYAxisAnchor

        for (index, line) in horizontalLines.enumerated() {
            if horizontalLines.indices.contains(index + 1) {
                let nextLine = horizontalLines[index + 1]

                guard let nextLineTopAnchorConstraint = nextLine.topAnchorLineConstraint,
                      let currentLineTopAnchorConstraint = line.topAnchorLineConstraint else { continue
                }

                let spacing: CGFloat = nextLineTopAnchorConstraint.constant - currentLineTopAnchorConstraint.constant
                guard spacing > 0 else { continue }

                spacingLine = PPHorizontalLineSpacing()
                spacingLine.setSpacing(spacing)
                spacingLine.aboveLine = line
                spacingLine.belowLine = nextLine

                prevLineAnchorY = line.lineView.bottomAnchor
                nextAnchorY = nextLine.lineView.topAnchor
            } else {
                guard let currentLineTopAnchorConstraint = line.topAnchorLineConstraint else { return }

                let spacing: CGFloat = baseView.frame.height - currentLineTopAnchorConstraint.constant
                guard spacing > 0 else { continue }

                spacingLine = PPHorizontalLineSpacing()
                spacingLine.setSpacing(spacing)
                spacingLine.aboveLine = line

                prevLineAnchorY = line.lineView.bottomAnchor
                nextAnchorY = baseView.bottomAnchor
            }

            baseView.addSubview(spacingLine)
            horizontalLinesSpacings.append(spacingLine)

            let layoutGuideForSpacingLine = UILayoutGuide()
            baseView.addLayoutGuide(layoutGuideForSpacingLine)
            spacingLine.externalLayoutGuide = layoutGuideForSpacingLine

            let layoutGuideTopConstraint = layoutGuideForSpacingLine.topAnchor.constraint(equalTo: prevLineAnchorY, constant: 3)
            layoutGuideTopConstraint.priority = .defaultLow

            let layoutGuideBottomConstraint = layoutGuideForSpacingLine.bottomAnchor.constraint(equalTo: nextAnchorY, constant: -3)
            layoutGuideBottomConstraint.priority = .defaultLow

            NSLayoutConstraint.activate([
                layoutGuideTopConstraint,
                layoutGuideBottomConstraint,
                layoutGuideForSpacingLine.leadingAnchor.constraint(equalTo: baseView.leadingAnchor),
                layoutGuideForSpacingLine.trailingAnchor.constraint(equalTo: baseView.trailingAnchor),
            ])
        }
    }

    func createVerticalLinesSpacings() {
        guard let baseView else {
            Self.printError("Недоступно baseView - не удалось добавить Vertical Lines Spacings")
            return
        }

        var spacingLine: PPVerticalLineSpacing
        var prevLineAnchorX: NSLayoutXAxisAnchor
        var nextAnchorX: NSLayoutXAxisAnchor

        for (index, line) in verticalLines.enumerated() {
            if verticalLines.indices.contains(index + 1) {
                let nextLine = verticalLines[index + 1]

                guard let currentLineLeadingAnchor = line.leadingAnchorLineConstraint,
                      let nextLineLeadingAnchor = nextLine.leadingAnchorLineConstraint else { continue
                }

                let spacing: CGFloat = nextLineLeadingAnchor.constant - currentLineLeadingAnchor.constant
                guard spacing > 0 else { continue }

                spacingLine = PPVerticalLineSpacing()
                spacingLine.setSpacing(spacing)
                spacingLine.leftLine = line
                spacingLine.rightLine = nextLine

                prevLineAnchorX = line.lineView.trailingAnchor
                nextAnchorX = nextLine.lineView.leadingAnchor
            } else {
                guard let currentLineLeadingAnchorConstraint = line.leadingAnchorLineConstraint else { return }

                let spacing: CGFloat = baseView.frame.width - currentLineLeadingAnchorConstraint.constant
                guard spacing > 0 else { continue }

                spacingLine = PPVerticalLineSpacing()
                spacingLine.setSpacing(spacing)
                spacingLine.leftLine = line

                prevLineAnchorX = line.lineView.trailingAnchor
                nextAnchorX = baseView.trailingAnchor
            }

            baseView.addSubview(spacingLine)
            verticalLinesSpacings.append(spacingLine)

            let layoutGuideForSpacingLine = UILayoutGuide()
            baseView.addLayoutGuide(layoutGuideForSpacingLine)
            spacingLine.externalLayoutGuide = layoutGuideForSpacingLine

            let layoutGuideLeadingConstraint = layoutGuideForSpacingLine.leadingAnchor.constraint(equalTo: prevLineAnchorX, constant: 2)
            layoutGuideLeadingConstraint.priority = .defaultLow

            let layoutGuideTrailingConstraint = layoutGuideForSpacingLine.trailingAnchor.constraint(equalTo: nextAnchorX, constant: -2)
            layoutGuideTrailingConstraint.priority = .defaultLow

            NSLayoutConstraint.activate([
                layoutGuideLeadingConstraint,
                layoutGuideTrailingConstraint,
                layoutGuideForSpacingLine.topAnchor.constraint(equalTo: baseView.topAnchor),
                layoutGuideForSpacingLine.bottomAnchor.constraint(equalTo: baseView.bottomAnchor)
            ])
        }
    }

    func updateHorizontalLinesSpacingsInfo() {
        horizontalLinesSpacings.forEach { spacingLine in
            spacingLine.updateSpacingByAboveAndBelowLinesOrBottom()
        }
    }

    func updateVerticalLinesSpacingsInfo() {
        verticalLinesSpacings.forEach { spacingLine in
            spacingLine.updateSpacingByLeftAndRightLinesOrRight()
        }
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

    @objc func sliderDidEndChangeValue(slider: PPSlider) {
        let newValue = round(slider.value)
        saveSliderCurrentValueToUD(sliderConfig: slider.config, value: newValue)

        let sliderValues = calculateValuesForSlider(
            config: slider.config,
            currentValue: newValue,
            slider: slider
        )
        slider.minimumValue = sliderValues.min
        slider.maximumValue = sliderValues.max
    }

    @objc func sliderDoubleTap(slider: PPSlider) {
        slider.isHidden = !slider.isHidden
    }

    @objc func imagePanGestureHandler(_ sender: UIPanGestureRecognizer) {
        guard let senderView = sender.view,
              let superview = senderView.superview else { return }

        let location = sender.location(in: senderView)

        if location.y < senderView.bounds.height  / 4 {
            changeImageLeftOffset(superview, sender)
        } else if location.x > senderView.bounds.width / 3 {
            changeImageAlpha(superview, sender)
        } else {
            changeImageTopOffset(superview, sender)
        }

        func changeImageAlpha(_ superView: UIView, _ sender: UIPanGestureRecognizer) {
            let translationPoint = sender.translation(in: superView)
            let translationPointY = CGFloat(translationPoint.y)

            var newValue: CGFloat = 0
            if translationPointY < 0 {
                newValue = screenImageView.alpha + (abs(translationPointY) / 200)
                screenImageView.alpha = newValue >= 1 ? 1 : newValue
            } else if translationPointY > 0 {
                newValue = screenImageView.alpha - (abs(translationPointY) / 200)
                screenImageView.alpha = newValue <= 0 ? 0.05 : newValue
            }

            sender.setTranslation(CGPoint.zero, in: superView)
        }

        func changeImageTopOffset(_ superView: UIView, _ sender: UIPanGestureRecognizer) {
            guard let currentTopOffset = screenTopConstraint?.constant else { return }

            let translationPoint = sender.translation(in: superView)
            let translationPointY = Int(translationPoint.y)

            if translationPointY != 0 {
                screenTopConstraint?.constant = currentTopOffset + CGFloat(translationPointY)
                sender.setTranslation(CGPoint.zero, in: superView)
            }

            if sender.state == .ended || sender.state == .cancelled {
                postNotificationMenuStateDidUpdated()
            }
        }

        func changeImageLeftOffset(_ superView: UIView, _ sender: UIPanGestureRecognizer) {
            guard let currentLeadingOffset = screenLeadingConstraint?.constant else { return }

            let translationPoint = sender.translation(in: superView)
            let translationPointX = Int(translationPoint.x)

            if translationPointX != 0 {
                screenLeadingConstraint?.constant = currentLeadingOffset + CGFloat(translationPointX)
                sender.setTranslation(CGPoint.zero, in: superView)
            }

            if sender.state == .ended || sender.state == .cancelled {
                postNotificationMenuStateDidUpdated()
            }
        }
    }

    @objc func updateMenuForActionsMenuButton() {
        actionsMenuButton.menu = buildActionsMenu()
    }

    @objc func addHorizontalLineMenuItemDidSelect() {
        addHorizontalLine()
    }

    @objc func addVerticalLineMenuItemDidSelect() {
        addVerticalLine()
    }

    @objc func controlsDidMove(_ sender: UIPanGestureRecognizer) {
        guard let superview = sender.view?.superview else { return }
        guard let controlsBottomConstraintConstant = controlsBottomConstraint?.constant else { return }

        let translationPoint = sender.translation(in: superview)

        let translationPointY = CGFloat(round(translationPoint.y))
        if translationPointY != 0 {
            controlsBottomConstraint?.constant = controlsBottomConstraintConstant + translationPointY
            sender.setTranslation(CGPoint.zero, in: superview)
        }
    }

    @objc func isVisibleLinesSpacingMenuItemSelected() {
        switchIsVisibleLinesSpacings()
    }

    @objc func rebuildLinesSpacingMenuItemSelected() {
        reloadLinesSpacings(forceRebuildHorizontal: true, forceRebuildVertical: true)
    }

    @objc func isVisibleSlidersItemSelected() {
        isVisibleSliders = !isVisibleSliders

        sliders.forEach { slider in
            slider.isHidden = !isVisibleSliders
        }
    }

    func saveCurrentTopOffsetMenuActionHandler() {
        let currentOffset = self.screenTopConstraint?.constant

        if let currentOffset {
            self.saveImageTopOffsetValueToUD(Int(currentOffset))
            self.updateMenuForActionsMenuButton()
            Self.printMessage(prefix: "✅➕", "Image top offset saved (\(currentOffset))")
        } else {
            Self.printError("Image top offset don't saved")
        }
    }

    func saveCurrentLeadingOffsetMenuActionHandler() {
        let currentOffset = self.screenLeadingConstraint?.constant

        if let currentOffset {
            self.saveImageLeadingOffsetValueToUD(Int(currentOffset))
            self.updateMenuForActionsMenuButton()
            Self.printMessage(prefix: "✅➕", "Image leading offset saved (\(currentOffset))")
        } else {
            Self.printError("Image leading offset don't saved")
        }
    }

    func deleteCurrentTopOffsetMenuActionHandler() {
        self.removeImageTopOffsetValueFromUD()
        self.screenTopConstraint?.constant = 0
        self.updateMenuForActionsMenuButton()

        Self.printMessage(prefix: "✅🗑️", "Image top offset deleted")
    }

    func deleteCurrentLeadingOffsetMenuActionHandler() {
        self.removeImageLeadingOffsetValueFromUD()
        self.screenLeadingConstraint?.constant = 0
        self.updateMenuForActionsMenuButton()

        Self.printMessage(prefix: "✅🗑️", "Image leading offset deleted")
    }

    // MARK: - Helper UserDefaults

    func saveImageTopOffsetValueToUD(_ value: Int) {
        userDefaults?.setValue(
            value,
            forKey: getImageTopOffsetUDKey()
        )
    }

    func removeImageTopOffsetValueFromUD() {
        userDefaults?.removeObject(forKey: getImageTopOffsetUDKey())
    }

    func getImageTopOffsetValueFromUD() -> Int {
        return userDefaults?.integer(forKey: getImageTopOffsetUDKey()) ?? 0
    }

    func getImageTopOffsetUDKey() -> String {
        return "\(imageName)_\(PPConstants.imageTopOffsetKeyUD)"
    }

    func saveImageLeadingOffsetValueToUD(_ value: Int) {
        userDefaults?.setValue(
            value,
            forKey: getImageLeadingOffsetUDKey()
        )
    }

    func removeImageLeadingOffsetValueFromUD() {
        userDefaults?.removeObject(forKey: getImageLeadingOffsetUDKey())
    }

    func getImageLeadingOffsetValueFromUD() -> Int {
        return userDefaults?.integer(forKey: getImageLeadingOffsetUDKey()) ?? 0
    }

    func getImageLeadingOffsetUDKey() -> String {
        return "\(imageName)_\(PPConstants.imageLeadingOffsetKeyUD)"
    }

    func saveSliderCurrentValueToUD(sliderConfig: PPSliderConfig, value: Float) {
        guard let sliderTitle = sliderConfig.title else { return }
        let sliderUDCurrentValueKey = buildSliderCurrentValueUDKey(sliderTitle: sliderTitle)

        userDefaults?.setValue(value, forKey: sliderUDCurrentValueKey)
    }

    func getSliderCurrentValueFromUD(sliderConfig: PPSliderConfig) -> Float? {
        guard let sliderTitle = sliderConfig.title else { return nil }
        let sliderUDCurrentValueKey = buildSliderCurrentValueUDKey(sliderTitle: sliderTitle)

        let value = userDefaults?.float(forKey: sliderUDCurrentValueKey)

        return (value != 0 && value != nil) ? value : nil
    }

    func buildSliderCurrentValueUDKey(sliderTitle: String) -> String {
        let validTitleForKey = makeValidUserDefaultsKey(from: sliderTitle)

        return "\(imageName)_\(PPConstants.sliderCurrentValueKeyUD)_\(validTitleForKey)"
    }

    func makeValidUserDefaultsKey(from string: String) -> String {
        let allowedCharacters = CharacterSet.alphanumerics.union(.init(charactersIn: "-._"))
        let filteredString = string.unicodeScalars.map { allowedCharacters.contains($0) ? Character($0) : "_" }

        return String(filteredString)
    }

    // MARK: - Helpers printing

    static func printError(_ text: String) {
        Self.printMessage(prefix: "❌ ❌ ❌", text)
    }

    static func printMessage(prefix: String, _ text: String) {
        print("\(prefix) PIXEL PERFECT SCREEN: \(text)")
    }

    // MARK: - Helpers for Menu button

    func buildActionsMenu() -> UIMenu {
        let addHorizontalLineItem = UIAction(
            title: "Add Horizontal line",
            image: UIImage(systemName: "equal")
        ) { [weak self]  (_) in
            self?.addHorizontalLineMenuItemDidSelect()
        }

        let addVerticalLineItem = UIAction(
            title: "Add Vertical line",
            image: UIImage(systemName: "pause")
        ) { [weak self] (_) in
            self?.addVerticalLineMenuItemDidSelect()
        }

        // submenuLinesSpacings

        var submenuItemsLinesSpacings: [UIAction] = []

        let showHideLinesSpacings = UIAction(
            title: "Show Line spacings",
            image: UIImage(systemName: "arrow.up.and.down.text.horizontal"),
            state: isVisibleLinesSpacings ? .on : .off
        ) { [weak self] (_) in
            self?.isVisibleLinesSpacingMenuItemSelected()
            self?.postNotificationMenuStateDidUpdated()
        }
        submenuItemsLinesSpacings.append(showHideLinesSpacings)

        if isVisibleLinesSpacings {
            let rebuildLinesSpacings = UIAction(
                title: "Rebuild Line spacings",
                image: UIImage(systemName: "arrow.clockwise")
            ) { [weak self] (_) in
                self?.rebuildLinesSpacingMenuItemSelected()
            }
            submenuItemsLinesSpacings.append(rebuildLinesSpacings)
        }

        let submenuLinesSpacings = UIMenu(
            title: "",
            options: .displayInline,
            children: submenuItemsLinesSpacings
        )

        // submenuImageTopOffset

        var submenuImageTopOffsetChildren: [UIAction] = []

        let deleteImageTopOffset = UIAction(
            title: "Delete top offset",
            image: UIImage(systemName: "delete.right"),
            attributes: [.destructive]
        ) { [weak self] (_) in
            self?.deleteCurrentTopOffsetMenuActionHandler()
        }
        submenuImageTopOffsetChildren.append(deleteImageTopOffset)

        let imageTopOffsetAsString = getCurrentImageTopOffsetAsString()
        let saveImageTopOffset = UIAction(
            title: "Save top offset \(imageTopOffsetAsString)",
            image: UIImage(systemName: "dock.arrow.down.rectangle")
        ) { [weak self] (_) in
            self?.saveCurrentTopOffsetMenuActionHandler()
        }
        submenuImageTopOffsetChildren.append(saveImageTopOffset)

        let submenuImageTopOffset = UIMenu(
            title: "",
            options: .displayInline,
            children: submenuImageTopOffsetChildren
        )

        // submenuImageLeadingOffset

        var submenuImageLeadingOffsetChildren: [UIAction] = []

        let deleteImageLeadingOffset = UIAction(
            title: "Delete leading offset",
            image: UIImage(systemName: "delete.right"),
            attributes: [.destructive]
        ) { [weak self] (_) in
            self?.deleteCurrentLeadingOffsetMenuActionHandler()
        }
        submenuImageLeadingOffsetChildren.append(deleteImageLeadingOffset)

        let imageLeadingOffsetAsString = getCurrentImageLeadingOffsetAsString()
        let saveImageLeadingOffset = UIAction(
            title: "Save leading offset \(imageLeadingOffsetAsString)",
            image: UIImage(systemName: "rectangle.righthalf.inset.filled.arrow.right")
        ) { [weak self] (_) in
            self?.saveCurrentLeadingOffsetMenuActionHandler()
        }
        submenuImageLeadingOffsetChildren.append(saveImageLeadingOffset)

        let submenuImageLeadingOffset = UIMenu(
            title: "",
            options: .displayInline,
            children: submenuImageLeadingOffsetChildren
        )

        // submenuOthers

        let isVisibleSlidersAction = UIAction(
            title: "Show sliders",
            image: UIImage(systemName: "slider.horizontal.3"),
            state: isVisibleSliders ? .on : .off
        ) { [weak self] (_) in
            self?.isVisibleSlidersItemSelected()
            self?.postNotificationMenuStateDidUpdated()
        }

        let submenuOthers = UIMenu(
            title: "",
            options: .displayInline,
            children: [isVisibleSlidersAction]
        )

        return UIMenu(
            title: "",
            children: [
                addHorizontalLineItem,
                addVerticalLineItem,
                submenuLinesSpacings,
                submenuImageLeadingOffset,
                submenuImageTopOffset,
                submenuOthers,
            ]
        )

        // indirect functions

        func getCurrentImageTopOffsetAsString() -> String {
            if let imageTopOffset = screenTopConstraint?.constant {
                return String(Int(imageTopOffset))
            } else {
                return "??"
            }
        }

        func getCurrentImageLeadingOffsetAsString() -> String {
            if let imageLeadingOffset = screenLeadingConstraint?.constant {
                return String(Int(imageLeadingOffset))
            } else {
                return "??"
            }
        }
    }

    // MARK: - Other helpers

    func postNotificationMenuStateDidUpdated() {
        NotificationCenter.default.post(
            name: PPNotifications.actionsMenuStateUpdated,
            object: nil,
            userInfo: nil
        )
    }

    func addControlsMovePanGestureRecognizerTo(view: UIView) {
        view.addGestureRecognizer(
            UIPanGestureRecognizer(target: self, action: #selector(controlsDidMove(_:)))
        )
    }

    func calculateValuesForSlider(
        config: PPSliderConfig,
        currentValue: Float? = nil,
        slider: PPSlider? = nil
    ) -> (min: Float, max: Float, current: Float) {
        let currentValue = currentValue ?? getSliderCurrentValueFromUD(sliderConfig: config)
        var minValue = slider?.minimumValue ?? config.minValue
        var maxValue = slider?.maximumValue ?? config.maxValue

        let total = maxValue - minValue
        let percent10 = total * 0.1
        let percent25 = total * 0.25

        if let currentValue {
            if currentValue <= minValue + percent10 {
                minValue = min(currentValue, minValue) - percent25
            }

            if currentValue >= maxValue - percent10 {
                maxValue = max(currentValue, maxValue) + percent25
            }
        }

        return (
            min: minValue,
            max: maxValue,
            current: currentValue ?? config.initialValue
        )
    }

}

// MARK: - PPSlider

extension PIXEL_PERFECT_screen {
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

        private(set) var config: PPSliderConfig

        private lazy var label: UILabel = {
            $0.translatesAutoresizingMaskIntoConstraints = false
            $0.isUserInteractionEnabled = false
            $0.textColor = .white
            $0.shadowColor = .black
            $0.shadowOffset = .init(width: -1, height: 1)
            $0.layer.shadowOpacity = 1
            $0.layer.shadowRadius = 2
            $0.font = .systemFont(ofSize: 12)
            return $0
        }(UILabel())

        init(config: PPSliderConfig) {
            self.config = config
            super.init(frame: .zero)

            layer.zPosition = PPZPosition.control.asCgFloat
            translatesAutoresizingMaskIntoConstraints = false

            addSubview(label)
            NSLayoutConstraint.activate([
                label.trailingAnchor.constraint(equalTo: self.trailingAnchor, constant: 10),
                label.bottomAnchor.constraint(equalTo: self.centerYAnchor, constant: 5)
            ])
        }

        required init?(coder: NSCoder) {
            fatalError("init(coder:) has not been implemented")
        }
    }
}

// MARK: - PPHorizontalLineView

extension PIXEL_PERFECT_screen {
    fileprivate class PPHorizontalLineView: UIView {

        // MARK: - Settings

        private let color: UIColor = PPColorRandomizer.getColorForLine()

        // MARK: - Subviews

        lazy var lineView: UIView = {
            $0.translatesAutoresizingMaskIntoConstraints = false
            $0.backgroundColor = color
            return $0
        }(UIView())

        private lazy var moveButton: UIButton = {
            $0.translatesAutoresizingMaskIntoConstraints = false
            $0.setImage(UIImage(systemName: "arrowtriangle.left.and.line.vertical.and.arrowtriangle.right.fill"), for: .normal)
            $0.tintColor = color
            $0.transform = .init(rotationAngle: CGFloat.pi / 2)
            $0.menu = buildActionsMenu()
            return $0
        }(UIButton())

        private lazy var infoLabel: UILabel = {
            $0.translatesAutoresizingMaskIntoConstraints = false
            $0.textColor = color
            $0.font = .systemFont(ofSize: 12)
            return $0
        }(UILabel())

        // MARK: - Constraints

        var topAnchorLineConstraint: NSLayoutConstraint?

        private var moveButtonTrailingConstraint: NSLayoutConstraint?

        // MARK: - Other properties

        var removeLineClosure: ((PPHorizontalLineView) -> Void)? = nil

        var moveLineClosure: (() -> Void)? = nil

        // MARK: - Init

        convenience init() {
            self.init(frame: .zero)

            translatesAutoresizingMaskIntoConstraints = false
            layer.zPosition = PPZPosition.control.asCgFloat

            // lineView
            addSubview(lineView)
            NSLayoutConstraint.activate([
                lineView.heightAnchor.constraint(equalToConstant: 1),
                lineView.leadingAnchor.constraint(equalTo: self.leadingAnchor),
                lineView.trailingAnchor.constraint(equalTo: self.trailingAnchor),
                lineView.centerYAnchor.constraint(equalTo: self.centerYAnchor),
            ])

            // moveButton
            addSubview(moveButton)
            let buttonTrailingConstraint = moveButton.trailingAnchor.constraint(
                equalTo: self.trailingAnchor,
                constant: CGFloat(Int.random(in: -40...(-5)))
            )
            moveButtonTrailingConstraint = buttonTrailingConstraint
            NSLayoutConstraint.activate([
                moveButton.topAnchor.constraint(equalTo: self.topAnchor),
                moveButton.bottomAnchor.constraint(equalTo: self.bottomAnchor),
                moveButton.widthAnchor.constraint(equalTo: moveButton.heightAnchor),
                buttonTrailingConstraint,
                moveButton.centerYAnchor.constraint(equalTo: self.centerYAnchor),
            ])

            moveButton.addGestureRecognizer(
                UIPanGestureRecognizer(target: self, action: #selector(lineDidMovedByPanGesture(_:)))
            )

            // infoLabel
            addSubview(infoLabel)
            let infoLabelTrailingConstraint = infoLabel.trailingAnchor.constraint(equalTo: moveButton.leadingAnchor)
            infoLabelTrailingConstraint.priority = .defaultLow

            let infoLabelTopConstraint = infoLabel.topAnchor.constraint(equalTo: lineView.bottomAnchor, constant: 2)
            infoLabelTopConstraint.priority = .defaultLow

            NSLayoutConstraint.activate([
                infoLabelTrailingConstraint,
                infoLabelTopConstraint,
                infoLabel.leadingAnchor.constraint(greaterThanOrEqualTo: self.leadingAnchor, constant: 3),
            ])
        }

        // MARK: - Update view

        func addInfoLabelBottomConstraintRelatively(baseView: UIView) {
            NSLayoutConstraint.activate([
                infoLabel.bottomAnchor.constraint(lessThanOrEqualTo: baseView.bottomAnchor, constant: -2)
            ])
        }

        // MARK: - Lifecycle

        override func point(inside point: CGPoint, with event: UIEvent?) -> Bool {
            let pointInMoveButton = convert(point, to: moveButton)
            return moveButton.bounds.contains(pointInMoveButton)
        }

        // MARK: - Helpers

        func buildActionsMenu() -> UIMenu {
            let removeLine = UIAction(
                title: "Remove line",
                image: UIImage(systemName: "trash"),
                attributes: .destructive
            ) { [weak self]  (_) in
                self?.removeLineMenuItemDidSelect()
            }

            let setRedColor = UIAction(
                title: "Set red color",
                image: UIImage(systemName: "paintpalette")
            ) { [weak self]  (_) in
                self?.changeColorMenuItemDidSelect(.systemRed)
            }

            let setBlueColor = UIAction(
                title: "Set blue color",
                image: UIImage(systemName: "paintpalette")
            ) { [weak self]  (_) in
                self?.changeColorMenuItemDidSelect(.blue)
            }

            let setBlackColor = UIAction(
                title: "Set black color",
                image: UIImage(systemName: "paintpalette")
            ) { [weak self]  (_) in
                self?.changeColorMenuItemDidSelect(.black)
            }

            return UIMenu(title: "", children: [removeLine, setRedColor, setBlueColor, setBlackColor])
        }

        // MARK: - Actions handlers

        @objc private func lineDidMovedByPanGesture(_ sender: UIPanGestureRecognizer) {
            guard let superview = self.superview else { return }
            guard let topAnchorConstraintConstant = topAnchorLineConstraint?.constant else { return }
            guard let moveButtonTrailingConstant = moveButtonTrailingConstraint?.constant else { return }

            let translationPoint = sender.translation(in: superview)


            let translationPointY = CGFloat(round(translationPoint.y))
            if translationPointY != 0 {
                let newPointY = topAnchorConstraintConstant + translationPointY
                topAnchorLineConstraint?.constant = newPointY
                sender.setTranslation(CGPoint.zero, in: superview)

                infoLabel.text = "y: \(Int(newPointY))pt"
            }

            let translationPointX = CGFloat(round(translationPoint.x))
            if translationPointX != 0 {
                moveButtonTrailingConstraint?.constant = moveButtonTrailingConstant + translationPointX
                sender.setTranslation(CGPoint.zero, in: superview)
            }

            moveLineClosure?()
        }

        @objc private func removeLineMenuItemDidSelect() {
            self.removeLineClosure?(self)
        }

        @objc private func changeColorMenuItemDidSelect(_ color: UIColor) {
            lineView.backgroundColor = color
            moveButton.tintColor = color
            infoLabel.textColor = color
        }
    }
}

// MARK: - PPVerticalLineView

extension PIXEL_PERFECT_screen {
    fileprivate class PPVerticalLineView: UIView {

        // MARK: - Settings

        private let color: UIColor = PPColorRandomizer.getColorForLine()

        // MARK: - Subviews

        lazy var lineView: UIView = {
            $0.translatesAutoresizingMaskIntoConstraints = false
            $0.backgroundColor = color
            return $0
        }(UIView())

        private lazy var moveButton: UIButton = {
            $0.translatesAutoresizingMaskIntoConstraints = false
            $0.setImage(UIImage(systemName: "arrowtriangle.left.and.line.vertical.and.arrowtriangle.right.fill"), for: .normal)
            $0.tintColor = color
            $0.menu = buildActionsMenu()
            return $0
        }(UIButton())

        private lazy var infoLabel: UILabel = {
            $0.translatesAutoresizingMaskIntoConstraints = false
            $0.textColor = color
            $0.font = .systemFont(ofSize: 12)
            $0.numberOfLines = 0
            return $0
        }(UILabel())

        // MARK: - Constraints

        var leadingAnchorLineConstraint: NSLayoutConstraint?

        private var moveButtonBottomConstraint: NSLayoutConstraint?

        // MARK: - Other properties

        var removeLineClosure: ((PPVerticalLineView) -> Void)? = nil

        var moveLineClosure: (() -> Void)? = nil

        // MARK: - Init

        convenience init() {
            self.init(frame: .zero)

            layer.zPosition = PPZPosition.control.asCgFloat

            addSubview(lineView)
            NSLayoutConstraint.activate([
                lineView.widthAnchor.constraint(equalToConstant: 1),
                lineView.topAnchor.constraint(equalTo: self.topAnchor),
                lineView.bottomAnchor.constraint(equalTo: self.bottomAnchor),
                lineView.centerXAnchor.constraint(equalTo: self.centerXAnchor),
            ])

            addSubview(moveButton)
            let buttonBottomConstraint = moveButton.topAnchor.constraint(
                equalTo: self.bottomAnchor,
                constant: CGFloat(Int.random(in: -180...(-150)))
            )
            moveButtonBottomConstraint = buttonBottomConstraint
            NSLayoutConstraint.activate([
                buttonBottomConstraint,
                moveButton.leadingAnchor.constraint(equalTo: self.leadingAnchor),
                moveButton.trailingAnchor.constraint(equalTo: self.trailingAnchor),
                moveButton.heightAnchor.constraint(equalTo: moveButton.widthAnchor),
            ])

            let moveGesture = UIPanGestureRecognizer(target: self, action: #selector(lineDidMovedByPanGesture(_:)))
            moveButton.addGestureRecognizer(moveGesture)

            addSubview(infoLabel)
            let infoLabelLeadingConstraint = infoLabel.leadingAnchor.constraint(equalTo: lineView.trailingAnchor, constant: 3)
            infoLabelLeadingConstraint.priority = .defaultLow
            NSLayoutConstraint.activate([
                infoLabel.topAnchor.constraint(equalTo: moveButton.bottomAnchor, constant: 2),
                infoLabelLeadingConstraint,
            ])
        }

        // MARK: - Lifecycle

        override func point(inside point: CGPoint, with event: UIEvent?) -> Bool {
            let pointInMoveButton = convert(point, to: moveButton)
            return moveButton.bounds.contains(pointInMoveButton)
        }

        // MARK: - Update view

        func addInfoLabelTrailingConstraintRelatively(baseView: UIView) {
            NSLayoutConstraint.activate([
                infoLabel.trailingAnchor.constraint(lessThanOrEqualToSystemSpacingAfter: baseView.trailingAnchor, multiplier: -2),
            ])
        }

        // MARK: - Helpers

        func buildActionsMenu() -> UIMenu {
            let removeLine = UIAction(
                title: "Remove line",
                image: UIImage(systemName: "trash"),
                attributes: .destructive
            ) { [weak self]  (_) in
                self?.removeLineMenuItemDidSelect()
            }

            let setRedColor = UIAction(
                title: "Set red color",
                image: UIImage(systemName: "paintpalette")
            ) { [weak self]  (_) in
                self?.changeColorMenuItemDidSelect(.systemRed)
            }

            let setBlueColor = UIAction(
                title: "Set blue color",
                image: UIImage(systemName: "paintpalette")
            ) { [weak self]  (_) in
                self?.changeColorMenuItemDidSelect(.blue)
            }

            let setBlackColor = UIAction(
                title: "Set black color",
                image: UIImage(systemName: "paintpalette")
            ) { [weak self]  (_) in
                self?.changeColorMenuItemDidSelect(.black)
            }

            return UIMenu(title: "", children: [removeLine, setRedColor, setBlueColor, setBlackColor])
        }

        // MARK: - Actions handlers

        @objc private func lineDidMovedByPanGesture(_ sender: UIPanGestureRecognizer) {
            guard let superview = self.superview else { return }
            guard let leadingAnchorLineConstant = leadingAnchorLineConstraint?.constant else { return }
            guard let moveButtonBottomConstant = moveButtonBottomConstraint?.constant else { return }

            let translationPoint = sender.translation(in: superview)

            let translationPointX = CGFloat(round(translationPoint.x))
            if translationPointX != 0 {
                let newPointX = leadingAnchorLineConstant + translationPointX
                leadingAnchorLineConstraint?.constant = leadingAnchorLineConstant + translationPointX
                sender.setTranslation(CGPoint.zero, in: superview)

                infoLabel.text = "x:\n\(Int(newPointX))pt"
            }

            let translationPointY = CGFloat(round(translationPoint.y))
            if translationPointY != 0 {
                moveButtonBottomConstraint?.constant = moveButtonBottomConstant + translationPointY
                sender.setTranslation(CGPoint.zero, in: superview)
            }

            moveLineClosure?()
        }

        @objc private func removeLineMenuItemDidSelect() {
            self.removeLineClosure?(self)
        }

        @objc private func changeColorMenuItemDidSelect(_ color: UIColor) {
            lineView.backgroundColor = color
            moveButton.tintColor = color
            infoLabel.textColor = color
        }
    }
}

// MARK: - PPHorizontalLineSpacing

extension PIXEL_PERFECT_screen {
    fileprivate class PPHorizontalLineSpacing: UIView {

        // MARK: - Subviews

        private lazy var infoLabel: UILabel = {
            $0.translatesAutoresizingMaskIntoConstraints = false
            $0.font = .systemFont(ofSize: 12)
            $0.textColor = .red

            return $0
        }(UILabel())

        private lazy var arrowsImageView: UIImageView = {
            let image = UIImage(systemName: "arrow.up.and.down")
            let imageView = UIImageView(image: image)
            imageView.translatesAutoresizingMaskIntoConstraints = false
            imageView.tintColor = .red
            return imageView
        }()

        var externalLayoutGuide: UILayoutGuide? {
            didSet {
                updateConstraintByExternalLayoutGuide()
            }
        }

        // MARK: - Other

        // Линии к которым относится этот объект LineSpacing
        weak var aboveLine: PPHorizontalLineView?
        weak var belowLine: PPHorizontalLineView?

        // MARK: - Init

        convenience init() {
            self.init(frame: .zero)

            self.translatesAutoresizingMaskIntoConstraints = false
            layer.zPosition = PPZPosition.control.asCgFloat

            addSubview(infoLabel)
            NSLayoutConstraint.activate([
                infoLabel.topAnchor.constraint(equalTo: self.topAnchor),
                infoLabel.bottomAnchor.constraint(equalTo: self.bottomAnchor),
                infoLabel.leadingAnchor.constraint(equalTo: self.leadingAnchor),
            ])

            addSubview(arrowsImageView)
            NSLayoutConstraint.activate([
                arrowsImageView.heightAnchor.constraint(equalToConstant: 14),
                arrowsImageView.widthAnchor.constraint(equalToConstant: 9),
                arrowsImageView.leadingAnchor.constraint(equalTo: infoLabel.trailingAnchor, constant: 5),
                arrowsImageView.centerYAnchor.constraint(equalTo: self.centerYAnchor),
                arrowsImageView.trailingAnchor.constraint(equalTo: self.trailingAnchor),
            ])
        }

        // MARK: - Update view

        func setSpacing(_ spacing: CGFloat?) {
            guard let spacing else {
                infoLabel.text = "???"
                return
            }

            infoLabel.text = "\(Int(spacing))pt"
        }

        func updateSpacingByAboveAndBelowLinesOrBottom() {
            guard let aboveLineTopAnchorConstant = aboveLine?.topAnchorLineConstraint?.constant else {
                return
            }

            var spacing: CGFloat?
            if let belowLineTopAnchorConstant = belowLine?.topAnchorLineConstraint?.constant {
                spacing = belowLineTopAnchorConstant - aboveLineTopAnchorConstant
            } else if let superview = self.superview {
                spacing = superview.frame.height - aboveLineTopAnchorConstant
            } else {
                spacing = nil
            }

            setSpacing(spacing)
        }

        private func updateConstraintByExternalLayoutGuide() {
            guard let externalLayoutGuide = self.externalLayoutGuide else { return }

            let centerYAnchorConstraint = centerYAnchor.constraint(equalTo: externalLayoutGuide.centerYAnchor)
            centerYAnchorConstraint.priority = .defaultLow
            NSLayoutConstraint.activate([
                centerYAnchorConstraint,
                trailingAnchor.constraint(equalTo: externalLayoutGuide.trailingAnchor, constant: -10),
                bottomAnchor.constraint(lessThanOrEqualTo: externalLayoutGuide.bottomAnchor, constant: -2)
            ])
        }

    }
}

// MARK: - VerticalLineSpacing

extension PIXEL_PERFECT_screen {
    fileprivate class PPVerticalLineSpacing: UIView {

        // MARK: - Subviews

        private lazy var arrowsImageView: UIImageView = {
            let image = UIImage(systemName: "arrow.left.and.right")
            let imageView = UIImageView(image: image)
            imageView.translatesAutoresizingMaskIntoConstraints = false
            imageView.tintColor = .red
            return imageView
        }()

        private lazy var infoLabel: UILabel = {
            $0.translatesAutoresizingMaskIntoConstraints = false
            $0.font = .systemFont(ofSize: 12)
            $0.textColor = .red

            return $0
        }(UILabel())

        var externalLayoutGuide: UILayoutGuide? {
            didSet {
                updateConstraintByExternalLayoutGuide()
            }
        }

        // MARK: - Other

        // Линии к которым относится этот объект LineSpacing
        weak var leftLine: PPVerticalLineView?
        weak var rightLine: PPVerticalLineView?

        // MARK: - Init

        convenience init() {
            self.init(frame: .zero)

            self.translatesAutoresizingMaskIntoConstraints = false
            layer.zPosition = PPZPosition.control.asCgFloat

            addSubview(arrowsImageView)
            NSLayoutConstraint.activate([
                arrowsImageView.topAnchor.constraint(equalTo: self.topAnchor),
                arrowsImageView.heightAnchor.constraint(equalToConstant: 15),
                arrowsImageView.widthAnchor.constraint(equalToConstant: 16),
                arrowsImageView.centerXAnchor.constraint(equalTo: self.centerXAnchor),
            ])

            addSubview(infoLabel)
            NSLayoutConstraint.activate([
                infoLabel.topAnchor.constraint(equalTo: arrowsImageView.bottomAnchor),
                infoLabel.leadingAnchor.constraint(equalTo: self.leadingAnchor),
                infoLabel.trailingAnchor.constraint(equalTo: self.trailingAnchor),
                infoLabel.bottomAnchor.constraint(equalTo: self.bottomAnchor),
            ])
        }

        // MARK: - Update view

        func setSpacing(_ spacing: CGFloat?) {
            guard let spacing else {
                infoLabel.text = "???"
                return
            }

            infoLabel.text = "\(Int(spacing))pt"
        }

        func updateSpacingByLeftAndRightLinesOrRight() {
            guard let leftLineLeadingAnchorConstant = leftLine?.leadingAnchorLineConstraint?.constant else {
                return
            }

            var spacing: CGFloat?
            if let rightLineLeadingAnchorConstant = rightLine?.leadingAnchorLineConstraint?.constant {
                spacing = rightLineLeadingAnchorConstant - leftLineLeadingAnchorConstant
            } else if let superview = self.superview {
                spacing = superview.frame.width - leftLineLeadingAnchorConstant
            } else {
                spacing = nil
            }

            setSpacing(spacing)
        }

        private func updateConstraintByExternalLayoutGuide() {
            guard let externalLayoutGuide = self.externalLayoutGuide else { return }

            let centerXAnchorConstraint = centerXAnchor.constraint(equalTo: externalLayoutGuide.centerXAnchor)
            centerXAnchorConstraint.priority = .defaultLow

            NSLayoutConstraint.activate([
                centerXAnchorConstraint,
                bottomAnchor.constraint(equalTo: externalLayoutGuide.bottomAnchor, constant: -190),
                trailingAnchor.constraint(lessThanOrEqualTo: externalLayoutGuide.trailingAnchor, constant: -2),
            ])
        }

    }
}

// MARK: - Internal Code-entities

extension PIXEL_PERFECT_screen {

    struct PPSliderConfig {
        typealias SliderChangeValueHandler = (Float) -> Void

        var title: String?
        var initialValue: Float
        var minValue: Float
        var maxValue: Float
        var handler: SliderChangeValueHandler

        var titleForPrint: String {
            return title ?? "<без имени>"
        }
    }

    fileprivate struct PPNotifications {
        static let actionsMenuStateUpdated: Notification.Name = .init("actionsMenuStateUpdated")
    }

    fileprivate struct PPConstants {
        static let imageTopOffsetKeyUD = "imageTopOffset"
        static let imageLeadingOffsetKeyUD = "imageLeadingOffset"
        static let sliderCurrentValueKeyUD = "sliderCurrentValue"

        static let screenImageViewTag: Int = 7777

        static let defaultControlsBottomPadding: CGFloat = 0
        static let menuButtonSize: CGFloat = 30
    }

    fileprivate enum PPZPosition: Int {
        case control = 99999
        case image = 99998

        var asCgFloat: CGFloat {
            return CGFloat(self.rawValue)
        }
    }

    fileprivate struct PPColorRandomizer {
        static func getColorForLine() -> UIColor {
            let colors: [UIColor] = [.blue]
            return colors.randomElement() ?? .red
        }
    }
}
// swiftlint:enable all
