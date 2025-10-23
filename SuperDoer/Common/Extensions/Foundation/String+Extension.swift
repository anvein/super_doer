import Foundation

extension String {
    var firstLetterCapitalized: Self {
        let firstLetter = self.prefix(1).capitalized
        let stringWithoutFirst = self.dropFirst()

        return firstLetter + stringWithoutFirst
    }

    func normalizedWhitespaceOrNil() -> String? {
        let normalized = self.components(separatedBy: .whitespacesAndNewlines)
            .filter { !$0.isEmpty }
            .joined(separator: " ")

        return normalized.isEmpty ? nil : normalized
    }
}
