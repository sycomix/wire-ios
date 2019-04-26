//
// Wire
// Copyright (C) 2019 Wire Swiss GmbH
//
// This program is free software: you can redistribute it and/or modify
// it under the terms of the GNU General Public License as published by
// the Free Software Foundation, either version 3 of the License, or
// (at your option) any later version.
//
// This program is distributed in the hope that it will be useful,
// but WITHOUT ANY WARRANTY; without even the implied warranty of
// MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the
// GNU General Public License for more details.
//
// You should have received a copy of the GNU General Public License
// along with this program. If not, see http://www.gnu.org/licenses/.
//

import UIKit

/**
 * A class to handle emoji shortcuts (inline replacement and suggestions).
 */

@objc class EmojiShortcutsHandler: NSObject {

    /// The regex to use to detect standard inline emoticons.
    fileprivate static var inlineRegex: NSRegularExpression = {
        try! NSRegularExpression(pattern: "([\\s]|^)([^\\s]+)", options: [.anchorsMatchLines])
    }()

    /// The regex to use to detect shorthands such as :smile:
    fileprivate static var suggestionRegex: NSRegularExpression = {
        try! NSRegularExpression(pattern: "([\\s]|^)(:(\\w{2,}):?)", options: [.anchorsMatchLines])
    }()

    // MARK: - Properties

    /// The search string to use.
    let searchString: String

    /// The range of the text to replace.
    let replacementRange: NSRange

    // MARK: - Initialization

    init?(text: String?, cursorPosition: Int) {
        guard let text = text else { return nil }
        let wholeRange = NSRange(text.startIndex ..< text.endIndex, in: text)
        let characterPosition = max(0, cursorPosition - 1)

        let resultIsValidForNumberOfRanges: (Int) -> ((NSTextCheckingResult) -> Bool) = { numberOfRanges in
            return { $0.range.contains(characterPosition) && $0.numberOfRanges == numberOfRanges }
        }

        // 1) Try to detect inline emojis.
        let inlineMatches = EmojiShortcutsHandler.inlineRegex.matches(in: text, range: wholeRange)

        if let inlineMatch = inlineMatches.first(where: resultIsValidForNumberOfRanges(3)) {
            let matchRange = inlineMatch.range(at: 2)
            if let inlineMatchRange = Range<String.Index>(matchRange, in: text) {
                let inlineMatchText = String(text[inlineMatchRange])
                if let canonicalName = EmojiDirectory.shared.canonicalName(for: inlineMatchText) {
                    self.replacementRange = matchRange
                    self.searchString = canonicalName
                    return
                }
            }
        }

        // 2) Try to detect suggestions.
        let matches = EmojiShortcutsHandler.suggestionRegex.matches(in: text, range: wholeRange)
        guard let match = matches.first(where: resultIsValidForNumberOfRanges(4)) else { return nil }

        let matchRange = match.range(at: 3)
        guard let searchStringRange = Range<String.Index>(matchRange, in: text) else { return nil }
        searchString = String(text[searchStringRange])
        replacementRange = matchRange
    }

}

