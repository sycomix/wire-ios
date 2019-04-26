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

extension ConversationInputBarViewController {
    var isInEmojiShortcutsFlow: Bool {
        return emojiShortcutsHandler != nil
    }

    var canInsertEmojiSuggestion: Bool {
        guard isInEmojiShortcutsFlow, let emojiView = emojiShortcutsView else {
            return false
        }

        return true
    }

}

extension ConversationInputBarViewController: EmojiSuggestionsViewControllerDelegate {

    func emojiSuggestionsViewController(_ vc: EmojiSuggestionsViewController, didSelect suggestion: EmojiSuggestion) {
        defer {
            dismissEmojiShortcutsIfNeeded()
        }

        guard let handler = emojiShortcutsHandler else { return }
        let range = handler.replacementRange

        let replacementText = NSAttributedString(string: suggestion.replacement, attributes: inputBar.textView.typingAttributes)
        inputBar.textView.replace(range, withAttributedText: replacementText)

        playInputHapticFeedback()
        dismissMentionsIfNeeded()
    }

}

extension ConversationInputBarViewController {

    @objc func configureEmojiShortcutsView() {
        emojiShortcutsView?.delegate = self
    }

    @objc func dismissEmojiShortcutsIfNeeded() {
        emojiShortcutsHandler = nil
        emojiShortcutsView?.dismiss()
    }

    func triggerEmojiShortcutsIfNeeded(from textView: UITextView, with selection: UITextRange? = nil) {
        if let position = MentionsHandler.cursorPosition(in: textView, range: selection) {
            emojiShortcutsHandler = EmojiShortcutsHandler(text: textView.text, cursorPosition: position)
        }

        if let handler = emojiShortcutsHandler {
            let suggestions = EmojiDirectory.shared.suggestions(for: handler.searchString)
            emojiShortcutsView?.reloadTable(with: suggestions)
        } else {
            dismissEmojiShortcutsIfNeeded()
        }
    }

}
