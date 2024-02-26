
import UIKit

struct InterfaceColors {
    static let white = UIColor(white: 1, alpha: 1)
    static let whiteSelected = UIColor(white: 0.99, alpha: 1)
    
    static let lightGray = UIColor(white: 0.93, alpha: 1)
    
    static let controlsGray = UIColor(red: 109 / 255, green: 109 / 255, blue: 111 / 255, alpha: 1)
    static let textGray = UIColor(red: 118 / 255, green: 118 / 255, blue: 120 / 255, alpha: 1)
    
    static let textRed = UIColor(red: 227 / 255, green: 44 / 255, blue: 43 / 255, alpha: 1)
    static let textBlue = UIColor(red: 51 / 255, green: 111 / 255, blue: 238 / 255, alpha: 1)
//    static let textBlue = UIColor(red: 67 / 255, green: 106 / 255, blue: 242 / 255, alpha: 1)
    
    static let controlsLightBlueBg = UIColor(red: 245 / 255, green: 245 / 255, blue: 1, alpha: 1)
    
    static let completedCheckboxBg = UIColor(red: 108 / 255, green: 177 / 255, blue: 0, alpha: 1)
    static let unCompletedCheckboxBg = UIColor(red: 1, green: 1, blue: 1, alpha: 1)
    
    static let blackText = UIColor(red: 53 / 255, green: 55 / 255, blue: 51 / 255, alpha: 1)
    
    struct TaskViewButtonCell {
        static let separator = UIColor(white: 237 / 255, alpha: 1)
        
        static let bg = UIColor(white: 1, alpha: 1)
        static let selectedBg = UIColor(red: 245 / 255, green: 245 / 255, blue: 1, alpha: 1)
        
    }
    
    struct TaskDescriptionController {
        static let navBarSeparator = UIColor(white: 0.7, alpha: 1)
    }
    
    struct SystemSectionImage {
        static let myDay = UIColor(red: 185 / 255, green: 75 / 255, blue: 33 / 255, alpha: 1)
        static let important = UIColor(red: 172 / 255, green: 56 / 255, blue: 93 / 255, alpha: 1)
        static let planned = UIColor(red: 172 / 255, green: 56 / 255, blue: 159 / 255, alpha: 1)
        static let all = UIColor(red: 52 / 255, green: 54 / 255, blue: 61 / 255, alpha: 1)
        static let completed = UIColor(red: 22 / 255, green: 111 / 255, blue: 107 / 255, alpha: 1)
        static let withoutSection = UIColor(red: 92 / 255, green: 112 / 255, blue: 189 / 255, alpha: 1)
        static let defaultColor = UIColor(red: 51 / 255, green: 111 / 255, blue: 238 / 255, alpha: 1)
    }
    
    struct TableCell {
        static let orangeSwipeAction = UIColor.orange
    }
}
