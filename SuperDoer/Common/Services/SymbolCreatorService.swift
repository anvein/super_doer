import UIKit

final class SymbolCreatorService {
    func combineSymbols(
        symbolName1: String,
        symbolName2: String,
        pointSize: CGFloat,
        weight1: UIImage.SymbolWeight = .medium,
        weight2: UIImage.SymbolWeight = .regular
    ) -> UIImage? {
        let configuration1 = UIImage.SymbolConfiguration(pointSize: pointSize, weight: weight1)
        let configuration2 = UIImage.SymbolConfiguration(pointSize: pointSize, weight: weight2)

        guard let symbolImage1 = UIImage(systemName: symbolName1, withConfiguration: configuration1),
              let symbolImage2 = UIImage(systemName: symbolName2, withConfiguration: configuration2) else {
            return nil
        }

        let symbol1Size = symbolImage1.size
        let symbol2Size = symbolImage2.size

        let totalWidth = max(symbol1Size.width, symbol2Size.width)
        let totalHeight = max(symbol1Size.height, symbol2Size.height)

        let totalSize = CGSize(width: totalWidth, height: totalHeight)

        let renderer = UIGraphicsImageRenderer(size: totalSize)

        let image = renderer.image { _ in
            let rect1 = CGRect(x: 0, y: 0, width: totalWidth, height: totalHeight)
            symbolImage1.draw(in: rect1)

            let rect2 = CGRect(x: 0, y: 0, width: totalWidth, height: totalHeight)
            symbolImage2.draw(in: rect2)
        }

        return image
    }

}
