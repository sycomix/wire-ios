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
 * A cell that displays an emoji suggestion.
 */

class EmojiSuggestionCell: SeparatorCollectionViewCell {

    let emojiLabel = UILabel()
    let emojiNameLabel = UILabel()
    let contentStack = UIStackView()

    // MARK: - Initialization

    override func setUp() {
        super.setUp()
        separatorLeadingInset = 16

        emojiLabel.font = .normalLightFont
        contentStack.addArrangedSubview(emojiLabel)

        emojiNameLabel.font = .normalLightFont
        contentStack.addArrangedSubview(emojiNameLabel)

        contentStack.axis = .horizontal
        contentStack.spacing = 16
        contentStack.alignment = .center
        contentStack.distribution = .fill
        contentView.addSubview(contentStack)

        createConstraints()
    }

    private func createConstraints() {
        contentStack.translatesAutoresizingMaskIntoConstraints = false

        emojiLabel.setContentHuggingPriority(.required, for: .horizontal)
        emojiNameLabel.setContentHuggingPriority(.defaultLow, for: .horizontal)

        NSLayoutConstraint.activate([
            contentStack.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            contentStack.topAnchor.constraint(equalTo: contentView.topAnchor),
            contentStack.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            contentStack.bottomAnchor.constraint(equalTo: contentView.bottomAnchor)
        ])
    }

    // MARK: - Content

    func configure(with suggestion: EmojiSuggestion) {
        accessibilityIdentifier = "emoji-suggestion-\(suggestion.shortcut)"
        emojiLabel.text = suggestion.replacement
        emojiNameLabel.text = ":" + suggestion.shortcut + ":"
    }

    override func prepareForReuse() {
        super.prepareForReuse()
        emojiLabel.text = nil
        emojiNameLabel.text = nil
    }

    // MARK: - Themable

    override func applyColorScheme(_ colorSchemeVariant: ColorSchemeVariant) {
        super.applyColorScheme(colorSchemeVariant)
        emojiNameLabel.textColor = UIColor.from(scheme: .textForeground, variant: colorSchemeVariant)
    }

}
