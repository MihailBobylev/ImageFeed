//
//  ProfileTests.swift
//  Image FeedTests
//
//  Created by Михаил Бобылев on 05.07.2025.
//

@testable import Image_Feed
import XCTest

final class ProfileTests: XCTestCase {
    func testControllerCallsUpdateAvatar() {
        let viewController = ProfileViewController()
        let presenter = ProfilePresenterSpy()
        viewController.configure(presenter)
        
        _ = viewController.view
        NotificationCenter.default.post(name: ImagesListService.didChangeNotification, object: nil)
        RunLoop.current.run(until: Date().addingTimeInterval(2))
        XCTAssertTrue(presenter.updateAvatarCalled)
    }
    
    func testControllerCallsUpdateUserInfo() {
        let viewController = ProfileViewController()
        let presenter = ProfilePresenterSpy()
        viewController.presenter = presenter
        
        _ = viewController.view
        viewController.viewDidAppear(false)
        
        XCTAssertTrue(presenter.updateUserInfoCalled)
    }
    
    func testPresenterCallsUpdateAvatar() {
        let viewController = ProfileViewControllerSpy()
        let profileService = ProfileServiceMock()
        let profileImageService = ProfileImageServiceMock()
        let profileLogoutService = ProfileLogoutServiceMock()
        profileImageService.fetchProfileImageURL(username: "", {_ in})
        let presenter = ProfilePresenter(profileService: profileService,
                                         profileImageService: profileImageService,
                                         profileLogoutService: profileLogoutService)
        presenter.view = viewController
        presenter.updateAvatar()
        
        XCTAssertTrue(viewController.updateAvatarCalled)
    }
    
    func testPresenterCallsUpdateUserInfo() {
        let viewController = ProfileViewControllerSpy()
        let profileService = ProfileServiceMock()
        let profileImageService = ProfileImageServiceMock()
        profileService.fetchProfile("", completion: {_ in })
        let profileLogoutService = ProfileLogoutServiceMock()
        let presenter = ProfilePresenter(profileService: profileService,
                                         profileImageService: profileImageService,
                                         profileLogoutService: profileLogoutService)
        presenter.view = viewController
        presenter.updateUserInfo()
        
        XCTAssertTrue(viewController.updateUserInfoCalled)
    }
    
    func testPresenterCallsLogout() {
        let profileService = ProfileServiceMock()
        let profileImageService = ProfileImageServiceMock()
        let profileLogoutService = ProfileLogoutServiceMock()
        let presenter = ProfilePresenter(profileService: profileService,
                                         profileImageService: profileImageService,
                                         profileLogoutService: profileLogoutService)
        presenter.logout()
        
        XCTAssertTrue(profileLogoutService.logoutCalled)
    }
}
