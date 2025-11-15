import UIKit

class TaskSectionsSeparator: UIView {

    convenience init() {
        self.init(frame: .zero)

        let lineView = UIView()
        lineView.backgroundColor = .Common.graySeparator

        addSubview(lineView)

        lineView.snp.makeConstraints {
            $0.horizontalEdges.equalToSuperview().inset(16)
            $0.height.equalTo(1)
            $0.centerY.equalToSuperview()
        }
    }

}
