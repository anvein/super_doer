
import UIKit

/// Класс для реализации наложения "скрина на экран"
class PixelPerfectScreen {
    var topAnchorConstant: Float = 0
    var controlsBottomAnchorConstant: Float = 0
    
    // MARK: controls
    private var isViewScreen = false
    private lazy var screenIsVisibleSwitch = UISwitch()
    private lazy var screenOpacitySlider = UISlider()
    private let screenImageView = UIImageView(image: UIImage(named: "screen"))
    
    private let baseView: UIView
    
    private static var instance: PixelPerfectScreen?
    
    // MARK: init
    private init(baseView: UIView) {
        self.baseView = baseView
    }
    
    
    // MARK: methods
    static func getInstanceAndSetup(
        baseView: UIView,
        imageName: String? = nil,
        topAnchorConstant: Float = 0,
        controlsBottomAnchorConstant: Float = 0
    ) {
        PixelPerfectScreen.instance = PixelPerfectScreen(baseView: baseView)
        PixelPerfectScreen.instance?.setup(
            imageName: imageName,
            topAnchorConstant: topAnchorConstant,
            controlsBottomAnchorConstant: controlsBottomAnchorConstant
        )
    }
    
    private func setup(imageName: String? = nil, topAnchorConstant: Float, controlsBottomAnchorConstant: Float) {
        self.topAnchorConstant = topAnchorConstant
        self.controlsBottomAnchorConstant = controlsBottomAnchorConstant
        
        if let safeImageName = imageName {
            screenImageView.image = UIImage(named: safeImageName)
        }
        
        setupScreenVisibleControls()
        addSubviewsToBaseView()
        addConstraintScreenControls()
        switchScreenIsVisible(false)
    }
    
    private func switchScreenIsVisible(_ isViewScreen: Bool) {
        let imageView = baseView.viewWithTag(777)
        if imageView == nil {
//            screenImageView.frame = baseView.frame
//            screenImageView.contentMode = .scaleAspectFit
            screenImageView.layer.zPosition = 10
            screenImageView.layer.opacity = 0.5
            
            baseView.addSubview(screenImageView)
            
            NSLayoutConstraint.activate([
                screenImageView.topAnchor.constraint(equalTo: baseView.topAnchor, constant: topAnchorConstant.cgFloat),
                screenImageView.leftAnchor.constraint(equalTo: baseView.leftAnchor),
                screenImageView.rightAnchor.constraint(equalTo: baseView.rightAnchor),
                screenImageView.heightAnchor.constraint(equalToConstant: screenImageView.image!.size.height / 3), // hardcode
            ])
        }
        
        screenImageView.isHidden = !isViewScreen
        screenOpacitySlider.isHidden = !isViewScreen
    }
    
    private func setupScreenVisibleControls() {
        // screenImageView
        screenImageView.translatesAutoresizingMaskIntoConstraints = false
        screenImageView.tag = 777
        
        // screenIsVisibleSwitch
        screenIsVisibleSwitch.translatesAutoresizingMaskIntoConstraints = false
        screenIsVisibleSwitch.isOn = false
        screenIsVisibleSwitch.onTintColor = .systemOrange
        screenIsVisibleSwitch.thumbTintColor = .systemBlue
        screenIsVisibleSwitch.layer.zPosition = 99999
        screenIsVisibleSwitch.isHidden = false // hidden
        
        screenIsVisibleSwitch.addTarget(self, action: #selector(screenIsVisibleSwitchValueChange(tdSwitch: event:)), for: .valueChanged)
        
        // screenOpacitySlider
        screenOpacitySlider.translatesAutoresizingMaskIntoConstraints = false
        screenOpacitySlider.value = 30
        screenOpacitySlider.layer.zPosition = 99999
        screenOpacitySlider.minimumValue = 0
        screenOpacitySlider.maximumValue = 100
        screenOpacitySlider.isHidden = true // hidden
        
        screenOpacitySlider.addTarget(self, action: #selector(screenOpacitySliderValueChange(slider:)), for: .valueChanged)
    }
    
    private func addConstraintScreenControls() {
        // screenIsVisibleSwitch
        NSLayoutConstraint.activate([
            screenIsVisibleSwitch.leftAnchor.constraint(equalTo: baseView.leftAnchor, constant: 20),
            screenIsVisibleSwitch.bottomAnchor.constraint(
                equalTo: baseView.safeAreaLayoutGuide.bottomAnchor,
                constant: controlsBottomAnchorConstant.cgFloat
            ),
        ])

        // screenOpacitySlider
        NSLayoutConstraint.activate([
            screenOpacitySlider.leftAnchor.constraint(equalTo: screenIsVisibleSwitch.rightAnchor, constant: 20),
            screenOpacitySlider.rightAnchor.constraint(equalTo: baseView.safeAreaLayoutGuide.rightAnchor, constant: -20),
            screenOpacitySlider.bottomAnchor.constraint(
                equalTo: baseView.safeAreaLayoutGuide.bottomAnchor,
                constant: controlsBottomAnchorConstant.cgFloat
            ),
        ])
    }

    private func addSubviewsToBaseView() {
        baseView.addSubview(screenIsVisibleSwitch)
        baseView.addSubview(screenOpacitySlider)
    }
    
    @objc func screenIsVisibleSwitchValueChange(tdSwitch: UISwitch, event: UIEvent) {
        switchScreenIsVisible(tdSwitch.isOn)
    }
    
    @objc private func screenOpacitySliderValueChange(slider: UISlider) {
        screenImageView.layer.opacity =  slider.value / 100
    }
}
