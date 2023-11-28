
import UIKit

class TaskSectionsSeparator: UIView {
    
    let line = {
        let view = UIView()
        view.backgroundColor = InterfaceColors.lightGray
        view.translatesAutoresizingMaskIntoConstraints = false
        
        return view
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        addSubview(line)
        
        NSLayoutConstraint.activate([
            line.leadingAnchor.constraint(equalTo: self.leadingAnchor, constant: 16),
            line.trailingAnchor.constraint(equalTo: self.trailingAnchor, constant: -16),
            line.heightAnchor.constraint(equalToConstant: 1),
            line.centerYAnchor.constraint(equalTo: self.centerYAnchor),
        ])
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}
