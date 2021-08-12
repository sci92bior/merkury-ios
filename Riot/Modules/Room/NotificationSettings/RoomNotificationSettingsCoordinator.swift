// File created from ScreenTemplate
// $ createScreen.sh Room/NotificationSettings RoomNotificationSettings
/*
 Copyright 2021 New Vector Ltd
 
 Licensed under the Apache License, Version 2.0 (the "License");
 you may not use this file except in compliance with the License.
 You may obtain a copy of the License at
 
 http://www.apache.org/licenses/LICENSE-2.0
 
 Unless required by applicable law or agreed to in writing, software
 distributed under the License is distributed on an "AS IS" BASIS,
 WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 See the License for the specific language governing permissions and
 limitations under the License.
 */

import Foundation
import UIKit
import SwiftUI

final class RoomNotificationSettingsCoordinator: RoomNotificationSettingsCoordinatorType {
    
    // MARK: - Properties
    
    // MARK: Private
    private var roomNotificationSettingsViewModel: RoomNotificationSettingsViewModelType
    private let roomNotificationSettingsViewController: UIViewController
    
    // MARK: Public

    // Must be used only internally
    var childCoordinators: [Coordinator] = []
    
    weak var delegate: RoomNotificationSettingsCoordinatorDelegate?
    
    // MARK: - Setup
    
    init(room: MXRoom, presentedModally: Bool = true) {
        let roomNotificationService = RoomNotificationSettingsService(room: room)
        let avatarService = AvatarService(avatarGenerator: AvatarGenerator(), mediaManager: room.mxSession.mediaManager)
        
        let avatarData: AvatarInputOption?
        let showAvatar = presentedModally
        if #available(iOS 14.0.0, *) {
            avatarData = showAvatar ? .swiftUI(AvatarInput(
                mxContentUri: room.summary.avatar,
                itemId: room.roomId,
                displayName: room.summary.displayname
            )) : nil
        } else {
            avatarData = showAvatar ? .uiKit(RoomAvatarViewData(
                roomId: room.roomId,
                displayName: room.summary.displayname,
                avatarUrl: room.summary.avatar,
                mediaManager: room.mxSession.mediaManager
            )) : nil
        }
        
        let roomNotificationSettingsViewModel = RoomNotificationSettingsViewModel(
            roomNotificationService: roomNotificationService,
            avatarService: avatarService,
            avatarData: avatarData,
            roomEncrypted: room.summary.isEncrypted)
        
        let viewController: UIViewController
        if #available(iOS 14.0.0, *) {
            let view = RoomNotificationSettingsView(viewModel: roomNotificationSettingsViewModel, presentedModally: presentedModally)
                .vectorContent()
            viewController = VectorHostingViewController(rootView: view)
        } else {
            viewController = RoomNotificationSettingsViewController.instantiate(with: roomNotificationSettingsViewModel)
        }
        self.roomNotificationSettingsViewModel = roomNotificationSettingsViewModel
        self.roomNotificationSettingsViewController = viewController
    }

    // MARK: - Public methods
    
    func start() {            
        self.roomNotificationSettingsViewModel.coordinatorDelegate = self
    }
    
    func toPresentable() -> UIViewController {
        return self.roomNotificationSettingsViewController
    }
}

// MARK: - RoomNotificationSettingsViewModelCoordinatorDelegate
extension RoomNotificationSettingsCoordinator: RoomNotificationSettingsViewModelCoordinatorDelegate {
    
    func roomNotificationSettingsViewModelDidComplete(_ viewModel: RoomNotificationSettingsViewModelType) {
        self.delegate?.roomNotificationSettingsCoordinatorDidComplete(self)
    }
    
    func roomNotificationSettingsViewModelDidCancel(_ viewModel: RoomNotificationSettingsViewModelType) {
        self.delegate?.roomNotificationSettingsCoordinatorDidCancel(self)
    }
}
