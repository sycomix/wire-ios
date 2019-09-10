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

import XCTest
@testable import Wire
import SnapshotTesting

final class MockConversationList: ConversationListType {
    static var hasArchivedConversations: Bool = false
}

final class ConversationListViewControllerTests: XCTestCase {
    
    var sut: ConversationListViewController!
    
    override func setUp() {
        super.setUp()

        MockConversationList.hasArchivedConversations = false
        let mockSelf = MockUser.mockSelf()!
        mockSelf.name = "Johannes Chrysostomus Wolfgangus Theophilus Mozart"
        let account = Account.mockAccount(imageData: mockImageData)
        let viewModel = ConversationListViewController.ViewModel(account: account, selfUser: mockSelf, conversationListType: MockConversationList.self)
        sut = ConversationListViewController(viewModel: viewModel)
        viewModel.viewController = sut

        sut.view.backgroundColor = .black
    }
    
    override func tearDown() {
        sut = nil
        super.tearDown()

    }

    //MARK: - View controller

    func testForNoConversations() {
        verify(matching: sut)
    }

    func testForEverythingArchived() {
        MockConversationList.hasArchivedConversations = true
        sut.showNoContactLabel(animated: false)
        verify(matching: sut)
    }

    //MARK: - PermissionDeniedViewController
    func testForPremissionDeniedViewController() {
        sut.showPermissionDeniedViewController()

        verify(matching: sut)
    }
}

final class ConversationListViewControllerViewModelSnapshotTests: CoreDataSnapshotTestCase {
    var sut: ConversationListViewController.ViewModel!
    var mockView: UIView!
    fileprivate var mockViewController: MockConversationListContainer!

    override func setUp() {
        super.setUp()

        let account = Account.mockAccount(imageData: Data())
        sut = ConversationListViewController.ViewModel(account: account, selfUser: MockUser.mockSelf())

        mockViewController = MockConversationListContainer(viewModel: sut)

        sut.viewController = mockViewController
    }

    override func tearDown() {
        sut = nil
        mockView = nil
        mockViewController = nil

        super.tearDown()
    }

    //MARK: - Action menu
    func testForActionMenu() {
        teamTest {
            sut.showActionMenu(for: otherUserConversation, from: mockViewController.view)
            verifyAlertController((sut?.actionsController?.alertController)!)
        }
    }

    func testForActionMenu_NoTeam() {
        nonTeamTest {
            sut.showActionMenu(for: otherUserConversation, from: mockViewController.view)
            verifyAlertController((sut?.actionsController?.alertController)!)
        }
    }
}


final class MockConversationListContainer: UIViewController, ConversationListContainerViewModelDelegate {

    var isSelectedOnListContentController = false

    init(viewModel: ConversationListViewController.ViewModel) {
        super.init(nibName:nil, bundle:nil)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    var hasUsernameTakeoverViewController: Bool {
        //no-op
        return false
    }

    @discardableResult
    func selectOnListContentController(_ conversation: ZMConversation!, scrollTo message: ZMConversationMessage?, focusOnView focus: Bool, animated: Bool, completion: (() -> Void)?) -> Bool {
        isSelectedOnListContentController = true
        return false
    }

    func updateBottomBarSeparatorVisibility(with controller: ConversationListContentController) {
    }

    func scrollViewDidScroll(scrollView: UIScrollView!) {
        //no-op
    }

    func setState(_ state: ConversationListState, animated: Bool, completion: Completion?) {
        completion?()
    }

    func showNoContactLabel(animated: Bool) {
        //no-op
    }

    func hideNoContactLabel(animated: Bool) {
        //no-op
    }

    func openChangeHandleViewController(with handle: String) {
        //no-op
    }

    func showNewsletterSubscriptionDialogIfNeeded(completionHandler: @escaping BoolResultHandler) {
        //no-op
    }

    func updateArchiveButtonVisibilityIfNeeded(showArchived: Bool) {
        //no-op
    }

    func removeUsernameTakeover() {
        //no-op
    }

    func showUsernameTakeover(suggestedHandle: String, name: String) {
        //no-op
    }

    func showPermissionDeniedViewController() {
        //no-op
    }
}
