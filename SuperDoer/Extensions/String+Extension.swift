
import Foundation

extension String {
    var firstLetterCapitalized: Self {
        let firstLetter = self.prefix(1).capitalized
        let stringWithoutFirst = self.dropFirst()

        return firstLetter + stringWithoutFirst
    }
}
