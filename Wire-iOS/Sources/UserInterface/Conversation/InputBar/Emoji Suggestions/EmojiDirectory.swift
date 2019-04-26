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

/**
 * The emoji skin tones.
 */

enum EmojiSkinTone: String {

    case none
    case light
    case mediumLight
    case medium
    case mediumDark
    case dark

    var modifier: String {
        switch self {
        case .none: return ""
        case .light: return "\u{1F3FB}"
        case .mediumLight: return "\u{1F3FC}"
        case .medium: return "\u{1F3FD}"
        case .mediumDark: return "\u{1F3FE}"
        case .dark: return "\u{1F3FF}"
        }
    }

}

private struct EmojiMatch {
    let suggestion: EmojiSuggestion
    let points: Int
}

enum EmojiTransform: String, Codable {
    case skinTone = "skin_tone"
    case suggestMan = "suggest_man"
    case suggestWoman = "suggest_woman"
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

    /// The transforms that can be applied to an emoji.
    let transforms: [String: Set<EmojiTransform>]

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
            .flatMap { self.expandedSuggestions(for: $0.key, initialReplacement: $0.value) }
            .sorted { $0.shortcut < $1.shortcut }

        matches.append(contentsOf: namedMatches)
        return matches
    }

    private func expandedSuggestions(for shortcut: String, initialReplacement: String) -> [EmojiSuggestion] {
        if let transforms = self.transforms[shortcut], !transforms.isEmpty {
            var results: [EmojiSuggestion] = []

            for transform in transforms {
                var transformedReplacement = initialReplacement

                switch transform {
                case .skinTone:
                    transformedReplacement += EmojiSkinTone.medium.modifier
                case .suggestMan:
                    if transforms.contains(.skinTone) {
                        transformedReplacement += EmojiSkinTone.medium.modifier
                    }

                    transformedReplacement += "\u{200D}\u{2642}\u{FE0F}"
                case .suggestWoman:
                    if transforms.contains(.skinTone) {
                        transformedReplacement += EmojiSkinTone.medium.modifier
                    }

                    transformedReplacement += "\u{200D}\u{2640}\u{FE0F}"
                }

                results.append(EmojiSuggestion(shortcut: shortcut, replacement: transformedReplacement))
            }

            return results
        } else {
            return [EmojiSuggestion(shortcut: shortcut, replacement: initialReplacement)]
        }
    }

    // MARK: - Matching

    func applyTransform(_ transform: EmojiTransform, to emoji: String) -> String {
        switch transform {
        case .skinTone:
            return emoji + "\u{1F3FC}"
        case .suggestMan:
            return emoji + "\u{200D}\u{2642}\u{FE0F}"
        case .suggestWoman:
            return emoji + "\u{200D}\u{2640}\u{FE0F}"
        }
    }

}
