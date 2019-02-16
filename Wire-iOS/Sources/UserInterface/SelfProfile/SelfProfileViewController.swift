//
// Wire
// Copyright (C) 2017 Wire Swiss GmbH
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
 * The view controller displaying the profile of the user and the
 * initial set of settings.
 */

class SelfProfileViewController: UIViewController {
    
    var userRightInterfaceType: UserRightInterface.Type = UserRight.self

    private let settingsController: SettingsTableViewController
    private let accountSelectorController = AccountSelectorController()
    private let profileContainerView = UIView()
    private let profileView: ProfileView
    
    internal var settingsCellDescriptorFactory: SettingsCellDescriptorFactory? = nil
    internal var rootGroup: (SettingsControllerGeneratorType & SettingsInternalGroupCellDescriptorType)? = nil

    convenience init(userRightInterfaceType: UserRightInterface.Type = UserRight.self) {
		
        let settingsPropertyFactory = SettingsPropertyFactory(userSession: SessionManager.shared?.activeUserSession, selfUser: ZMUser.selfUser())

		

		let settingsCellDescriptorFactory = SettingsCellDescriptorFactory(settingsPropertyFactory: settingsPropertyFactory, userRightInterfaceType: userRightInterfaceType)

		let rootGroup = settingsCellDescriptorFactory.rootGroup()

		self.init(rootGroup: rootGroup)

		self.userRightInterfaceType = userRightInterfaceType
		self.settingsCellDescriptorFactory = settingsCellDescriptorFactory
        self.rootGroup = rootGroup

        settingsPropertyFactory.delegate = self
    }
    
    init(rootGroup: SettingsControllerGeneratorType & SettingsInternalGroupCellDescriptorType) {
        settingsController = rootGroup.generateViewController()! as! SettingsTableViewController
        profileView = ProfileView(user: ZMUser.selfUser(), options: [.allowEditingAvailability])
        super.init(nibName: .none, bundle: .none)
                
        profileView.source = self
        profileView.imageView.addTarget(self, action: #selector(userDidTapProfileImage), for: .touchUpInside)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Configuration
    
    override var supportedInterfaceOrientations : UIInterfaceOrientationMask {
        return [.portrait]
    }
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }
    
    // MARK: - Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if ZMUser.selfUser()?.isTeamMember != true {
            profileView.options.insert(.hideAvailability)
        }
        
        profileContainerView.addSubview(profileView)
        
        settingsController.willMove(toParent: self)
        addChild(settingsController)
        view.addSubview(settingsController.view)
        settingsController.didMove(toParent: self)

        settingsController.tableView.tableHeaderView = profileContainerView
        
        createCloseButton()
        configureAccountTitle()
        createConstraints()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)

        if !presentNewLoginAlertControllerIfNeeded() {
            presentUserSettingChangeControllerIfNeeded()
        }
    }

    private func createCloseButton() {
        navigationItem.rightBarButtonItem = navigationController?.closeItem()
    }
    
    private func configureAccountTitle() {
        if SessionManager.shared?.accountManager.accounts.count > 1 {
            navigationItem.titleView = accountSelectorController.view
        } else {
            title = "self.account".localized(uppercased: true)
        }
    }
    
    private func createConstraints() {
        accountSelectorController.view.translatesAutoresizingMaskIntoConstraints = false
        settingsController.view.translatesAutoresizingMaskIntoConstraints = false
        profileView.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            // accountSelectorController
            accountSelectorController.view.heightAnchor.constraint(equalToConstant: 44),
            
            // settingsControllerView
            settingsController.view.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            settingsController.view.topAnchor.constraint(equalTo: safeTopAnchor),
            settingsController.view.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            settingsController.view.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            
            // profileView
            profileView.leadingAnchor.constraint(equalTo: profileContainerView.leadingAnchor),
            profileView.topAnchor.constraint(equalTo: profileContainerView.topAnchor),
            profileView.trailingAnchor.constraint(equalTo: profileContainerView.trailingAnchor),
            profileView.bottomAnchor.constraint(equalTo: profileContainerView.bottomAnchor)
        ])
    }

    // MARK: - Events
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        // Update the header
        guard let headerView = settingsController.tableView.tableHeaderView else {
            return
        }
        
        let size = headerView.systemLayoutSizeFitting(UIView.layoutFittingCompressedSize)

        if headerView.frame.size.height != size.height {
            headerView.frame.size.height = size.height
            settingsController.tableView.tableHeaderView = headerView
            settingsController.tableView.layoutIfNeeded()
        }
    }
    
    override func accessibilityPerformEscape() -> Bool {
        dismiss(animated: true)
        return true
    }
    
    @objc private func userDidTapProfileImage(sender: UserImageView) {
        guard userRightInterfaceType.selfUserIsPermitted(to: .editProfilePicture) else { return }
        
        let profileImageController = ProfileSelfPictureViewController()
        self.present(profileImageController, animated: true, completion: .none)
    }
    
}

// MARK: - SettingsPropertyFactoryDelegate

extension SelfProfileViewController: SettingsPropertyFactoryDelegate {
    
    func asyncMethodDidStart(_ settingsPropertyFactory: SettingsPropertyFactory) {
        self.navigationController?.showLoadingView = true
    }
    
    func asyncMethodDidComplete(_ settingsPropertyFactory: SettingsPropertyFactory) {
        self.navigationController?.showLoadingView = false
    }
    
}
