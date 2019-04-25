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

import Foundation

/**
 * Represents an emoji suggestion.
 */

struct EmojiSuggestion {
    let shortcut: String
    let replacement: String
}

private struct EmojiMatch {
    let suggestion: EmojiSuggestion
    let points: Int
}

class EmojiDirectory: Decodable {

    /// Returns the shared emoji directory.
    static let shared: EmojiDirectory = {
        assert(Thread.isMainThread)
        let fileURL = Bundle.main.url(forResource: "EmojiDirectory", withExtension: "json")!
        let fileData = try! Data(contentsOf: fileURL)
        return try! JSONDecoder().decode(EmojiDirectory.self, from: fileData)
    }()

    /// The map from unnamed symbol to the name of the symbol.
    let unnamedSymbols: [String: String]

    /// The map from symbol names to their Unicode representation.
    let namedSymbols: [String: String]

    // MARK: - Query

    func canonicalName(for inlineString: String) -> String? {
        return unnamedSymbols[inlineString]
    }

    func suggestions(for query: String) -> [EmojiSuggestion] {
        var matches: [EmojiSuggestion] = []

        if let emoticonName = unnamedSymbols[query] {
            matches = suggestions(for: emoticonName)
        }

        let namedMatches: [EmojiSuggestion] = namedSymbols
            .lazy
            .filter { $0.key.contains(query) }
            .map { EmojiSuggestion(shortcut: $0.key, replacement: $0.value) }
            .sorted { $0.shortcut < $1.shortcut }

        matches.append(contentsOf: namedMatches)
        return matches
    }

    // MARK: - Matching

}
