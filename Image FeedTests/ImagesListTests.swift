//
//  ImagesListTests.swift
//  Image FeedTests
//
//  Created by Михаил Бобылев on 06.07.2025.
//

@testable import Image_Feed
import XCTest

final class ImagesListTests: XCTestCase {
    func testViewControllerCallsViewDidLoad() {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        guard let viewController = storyboard.instantiateViewController(withIdentifier: "ImagesListViewController") as? ImagesListViewController else {
            XCTFail("Не удалось найти ImagesListViewController")
            return
        }
        let presenter = ImagesListPresenterSpy()
        viewController.presenter = presenter
        presenter.view = viewController
        
        _ = viewController.view
        
        XCTAssertTrue(presenter.viewDidLoadCalled)
    }
    
    func testConfigure_SetsPresenterAndView() {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        guard let viewController = storyboard.instantiateViewController(withIdentifier: "ImagesListViewController") as? ImagesListViewController else {
            XCTFail("Не удалось найти ImagesListViewController")
            return
        }
        let presenter = ImagesListPresenterSpy()
        
        viewController.configure(presenter)
        
        XCTAssertTrue(viewController.presenter === presenter)
        XCTAssertTrue(presenter.view === viewController)
    }
    
    func testUpdateTableViewAnimated_InsertsRows() {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        guard let viewController = storyboard.instantiateViewController(withIdentifier: "ImagesListViewController") as? ImagesListViewController else {
            XCTFail("Не удалось найти ImagesListViewController")
            return
        }
        _ = viewController.view

        let mockTableView = TableViewMock()
        viewController.setValue(mockTableView, forKey: "tableView")
        
        viewController.updateTableViewAnimated(oldCount: 0, newCount: 2)
        
        XCTAssertEqual(mockTableView.insertedIndexPaths.count, 2)
    }
    
    func testSetIsLiked_CallsCellMethod() {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        guard let viewController = storyboard.instantiateViewController(withIdentifier: "ImagesListViewController") as? ImagesListViewController else {
            XCTFail("Не удалось найти ImagesListViewController")
            return
        }
        let mockCell = ImagesListCellMock()

        viewController.setIsLiked(isLiked: true, on: mockCell)

        XCTAssertEqual(mockCell.likeSet, true)
    }
    
    func testViewDidLoad_CallsFetchPhotosNextPage() {
        let viewController = ImagesListViewControllerSpy()
        let service = ImagesListServiceMock()
        let tokenStorage = OAuth2TokenStorageMock()
        let presenter = ImagesListPresenter(imagesListService: service, oauth2TokenStorage: tokenStorage)
        viewController.presenter = presenter
        presenter.view = viewController
        
        presenter.viewDidLoad()

        XCTAssertTrue(service.didCallFetchPhotosNextPage)
    }
    
    func testFetchPhotosNextPage_WithoutToken_DoesNotCallService() {
        let service = ImagesListServiceMock()
        let tokenStorage = OAuth2TokenStorageMock()
        tokenStorage.token = nil

        let presenter = ImagesListPresenter(imagesListService: service, oauth2TokenStorage: tokenStorage)
        presenter.fetchPhotosNextPage()

        XCTAssertFalse(service.didCallFetchPhotosNextPage)
    }
    
    func testChangeLike_Success_UpdatesView() {
        let service = ImagesListServiceMock()
        let tokenStorage = OAuth2TokenStorageMock()
        let viewController = ImagesListViewControllerSpy()

        let photo = Photo(id: "1", size: .init(width: 10, height: 10), createdAt: nil, welcomeDescription: "", thumbImageURL: "url", largeImageURL: "url", isLiked: false)
        service.photos = [photo]
        service.changeLikeResult = .success(())
        
        let presenter = ImagesListPresenter(imagesListService: service, oauth2TokenStorage: tokenStorage)
        presenter.view = viewController
        presenter.photos = [photo]
        viewController.presenter = presenter
        
        let cell = ImagesListCellMock()
        presenter.changeLike(on: IndexPath(row: 0, section: 0), cell)

        XCTAssertTrue(service.didCallChangeLike)
    }
    
    func testChangeLike_Failure_ShowsError() {
        let service = ImagesListServiceMock()
        let tokenStorage = OAuth2TokenStorageMock()
        let viewController = ImagesListViewControllerSpy()

        let photo = Photo(id: "1", size: .init(width: 10, height: 10), createdAt: nil, welcomeDescription: "", thumbImageURL: "url", largeImageURL: "url", isLiked: true)
        service.photos = [photo]
        service.changeLikeResult = .failure(NSError(domain: "", code: -1))

        let presenter = ImagesListPresenter(imagesListService: service, oauth2TokenStorage: tokenStorage)
        presenter.view = viewController
        presenter.photos = [photo]
        viewController.presenter = presenter
        
        let cell = ImagesListCellMock()
        presenter.changeLike(on: IndexPath(row: 0, section: 0), cell)

        XCTAssertTrue(viewController.didShowLikeError)
    }
}
