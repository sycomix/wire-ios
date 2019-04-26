//
// Wire
// Copyright (C) 2018 Wire Swiss GmbH
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

protocol EmojiSuggestionsViewControllerDelegate: class {
    func emojiSuggestionsViewController(_ vc: EmojiSuggestionsViewController, didSelect suggestion: EmojiSuggestion)
}

/**
 * A view controller that shows a list of emoji suggestions.
 */

class EmojiSuggestionsViewController: UIViewController, KeyboardCollapseObserver {

    weak var delegate: EmojiSuggestionsViewControllerDelegate?

    private let collectionView = UICollectionView(frame: .zero, collectionViewLayout: UICollectionViewLayout())

    private var searchResults: [EmojiSuggestion] = [] {
        didSet {
            if searchResults.count > 0 {
                collectionViewSelectedIndex = searchResults.count - 1
            } else {
                collectionViewSelectedIndex = .none
            }
        }
    }
    private var query: String = ""
    private var collectionViewHeight: NSLayoutConstraint?
    private let rowHeight: CGFloat = 56.0
    private var isKeyboardCollapsedFirstCalled = true

    private var _collectionViewSelectedIndex : Int? = .none
    private var collectionViewSelectedIndex: Int? {
        get{
            return _collectionViewSelectedIndex
        }
        set{
            if let newValue = newValue {
                self._collectionViewSelectedIndex = min(searchResults.count - 1, max(0, newValue))
            } else {
                _collectionViewSelectedIndex = newValue
            }
        }
    }

    public private(set) var isKeyboardCollapsed: Bool = true {
        didSet {
            guard oldValue != isKeyboardCollapsed || isKeyboardCollapsedFirstCalled else { return }
            collectionView.reloadData()

            isKeyboardCollapsedFirstCalled = false
        }
    }


    private var keyboardObserver: KeyboardBlockObserver?

    override func viewDidLoad() {
        super.viewDidLoad()

        setupCollectionView()
        setupConstraints()

        NotificationCenter.default.addObserver(self,
                                               selector: #selector(keyboardWillChangeFrame(_:)),
                                               name: UIResponder.keyboardWillChangeFrameNotification,
                                               object: nil)

        setupKeyboardObserver()
    }

    private func setupKeyboardObserver() {
        keyboardObserver = KeyboardBlockObserver { [weak self] info in
            guard let weakSelf = self else { return }
            if let isKeyboardCollapsed = info.isKeyboardCollapsed {
                weakSelf.isKeyboardCollapsed = isKeyboardCollapsed
            }
        }
    }

    private func setupCollectionView() {
        view.isHidden = true

        collectionView.dataSource = self
        collectionView.delegate = self
        collectionView.register(EmojiSuggestionCell.self, forCellWithReuseIdentifier: EmojiSuggestionCell.reuseIdentifier)
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        collectionView.backgroundColor = UIColor.from(scheme: .barBackground)

        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .vertical
        layout.minimumLineSpacing = 0
        layout.minimumInteritemSpacing = 0

        collectionView.collectionViewLayout = layout

        view.backgroundColor = UIColor.black.withAlphaComponent(0.32)
        view.addSubview(collectionView)

        view.accessibilityIdentifier = "mentions.list.container"
        collectionView.accessibilityIdentifier = "mentions.list.collection"
    }

    private func setupConstraints() {
        collectionView.translatesAutoresizingMaskIntoConstraints = false

        collectionViewHeight = collectionView.heightAnchor.constraint(equalToConstant: 0)

        NSLayoutConstraint.activate([
            collectionViewHeight!,
            collectionView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            collectionView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            collectionView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
        ])
    }

    func reloadTable(with results: [EmojiSuggestion]) {
        searchResults = results
        resizeTable()

        collectionView.reloadData()
        collectionView.layoutIfNeeded()

        scrollToLastItem()

        if results.count > 0 {
            show()
        } else {
            dismiss()
        }
    }

    private func resizeTable() {
        let viewHeight = self.view.bounds.size.height
        let minValue = min(viewHeight, CGFloat(searchResults.count) * rowHeight)
        collectionViewHeight?.constant = minValue
        collectionView.isScrollEnabled = (minValue == viewHeight)
    }

    private func scrollToLastItem() {
        let firstMatchIndexPath = IndexPath(item: searchResults.count - 1, section: 0)

        if collectionView.containsCell(at: firstMatchIndexPath) {
            collectionView.scrollToItem(at: firstMatchIndexPath, at: .bottom, animated: false)
        }
    }

    func show() {
        view.isHidden = false
    }

    @objc dynamic func keyboardWillChangeFrame(_ notification: Notification) {
        guard let duration = notification.userInfo?[UIResponder.keyboardAnimationDurationUserInfoKey] as? TimeInterval else { return }
        resizeTable()
        UIView.animate(withDuration: duration) {
            self.view.layoutIfNeeded()
            self.scrollToLastItem()
        }
    }

    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        super.viewWillTransition(to: size, with: coordinator)

        coordinator.animate(alongsideTransition: nil) { _ in
            self.collectionView.reloadData()
        }
    }
}

extension EmojiSuggestionsViewController: Dismissable {
    func dismiss() {
        self.view.isHidden = true
        collectionViewSelectedIndex = .none
    }
}

//extension EmojiSuggestionsViewController: UserList {
//
//    var selectedSuggestion: EmojiSuggestion? {
//        guard let collectionViewSelectedIndex = collectionViewSelectedIndex else {
//            return .none
//        }
//
//        let bestSuggestion = searchResults[collectionViewSelectedIndex]
//        return bestSuggestion
//    }
//
//    func selectNextUser() {
////        guard let collectionViewSelectedIndex = collectionViewSelectedIndex else { return }
////
////        self.collectionViewSelectedIndex = collectionViewSelectedIndex + 1
////
////        updateHighlightedItem()
//    }
//
//    func selectPreviousUser() {
////        guard let collectionViewSelectedIndex = collectionViewSelectedIndex else { return }
////
////        self.collectionViewSelectedIndex = collectionViewSelectedIndex - 1
////
////        updateHighlightedItem()
//    }
//
//    func updateHighlightedItem() {
////        collectionView.reloadData()
////
////        guard let collectionViewSelectedIndex = collectionViewSelectedIndex else { return }
////
////        collectionView.scrollToItem(at: IndexPath(item: collectionViewSelectedIndex, section: 0), at: .centeredVertically, animated: true)
//    }
//
//    var users: [EmojiSuggestion] {
//        set {
//            reloadTable(with: newValue.reversed())
//        }
//        get {
//            return searchResults.reversed()
//        }
//    }
//}

extension EmojiSuggestionsViewController: UICollectionViewDelegate {

    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }

    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return searchResults.count
    }
}

extension EmojiSuggestionsViewController: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: collectionView.bounds.size.width, height: rowHeight)
    }
}

extension EmojiSuggestionsViewController: UICollectionViewDataSource {

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let suggestion = searchResults[indexPath.item]
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: EmojiSuggestionCell.reuseIdentifier, for: indexPath) as! EmojiSuggestionCell
        cell.configure(with: suggestion)
        cell.showSeparator = indexPath.item != (searchResults.count - 1)

        // hightlight the lowest cell if keyboard is collapsed
        if isKeyboardCollapsed || UIDevice.current.userInterfaceIdiom == .pad {
            if indexPath.item == collectionViewSelectedIndex {
                cell.backgroundColor = .from(scheme: .cellHighlight)
            } else {
                cell.backgroundColor = .from(scheme: .background)
            }
        } else {
            cell.backgroundColor = .from(scheme: .background)
        }

        return cell
    }

    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        delegate?.emojiSuggestionsViewController(self, didSelect: searchResults[indexPath.item])
        dismiss()
    }
}