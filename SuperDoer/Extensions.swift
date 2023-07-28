
import Foundation

extension Float {
    func round(digits: Int) -> Float? {
        let roundedString = String(format: "%.\(digits)f", self)
        
        return Float(roundedString)
    }
    
    var cgFloat: CGFloat {
        return CGFloat(self)
    }
}

extension Int {
    var cgFloat: CGFloat {
        return CGFloat(self)
    }
}
