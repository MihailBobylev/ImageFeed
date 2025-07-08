//
//  ImagesListPresenter.swift
//  Image Feed
//
//  Created by Михаил Бобылев on 05.07.2025.
//

import Foundation

public protocol ImagesListPresenterProtocol: AnyObject {
    var view: ImagesListViewControllerProtocol? { get set }
    var photos: [Photo] { get }
    func viewDidLoad()
    func fetchPhotosNextPage()
    func changeLike(on indexPath: IndexPath, _ cell: ImagesListCellProtocol)
}

final class ImagesListPresenter: ImagesListPresenterProtocol {
    weak var view: ImagesListViewControllerProtocol?
    
    private let imagesListService: ImagesListServiceProtocol
    private let oauth2TokenStorage: OAuth2TokenStorageProtocol
    var photos: [Photo] = []
    
    init(imagesListService: ImagesListServiceProtocol, oauth2TokenStorage: OAuth2TokenStorageProtocol) {
        self.imagesListService = imagesListService
        self.oauth2TokenStorage = oauth2TokenStorage
    }
    
    func viewDidLoad() {
        NotificationCenter.default.addObserver(
            forName: ImagesListService.didChangeNotification,
            object: nil,
            queue: .main) { _ in
                self.updateTableViewAnimated()
            }
        
        fetchPhotosNextPage()
    }
    
    func fetchPhotosNextPage() {
        guard let token = oauth2TokenStorage.token else {
            print("[fetchPhotosNextPage]: No auth token")
            return
        }
        
        imagesListService.fetchPhotosNextPage(authToken: token)
    }
    
    func changeLike(on indexPath: IndexPath, _ cell: ImagesListCellProtocol) {
        guard let token = oauth2TokenStorage.token else {
            print("[changeLike]: No auth token")
            return
        }
        
        let photo = photos[indexPath.row]
        
        UIBlockingProgressHUD.show()
        imagesListService.changeLike(photoId: photo.id, isLike: !photo.isLiked, authToken: token) { [weak self] result in
            UIBlockingProgressHUD.dismiss()
            guard let self else { return }
            switch result {
            case .success:
                photos = imagesListService.photos
                view?.setIsLiked(isLiked: photos[indexPath.row].isLiked, on: cell)
            case .failure:
                view?.showChangeLikeError()
            }
        }
    }
}

private extension ImagesListPresenter {
    func updateTableViewAnimated() {
        let oldCount = photos.count
        let newCount = imagesListService.photos.count
        photos = imagesListService.photos
        guard oldCount != newCount  else { return }
        view?.updateTableViewAnimated(oldCount: oldCount, newCount: newCount)
    }
}
