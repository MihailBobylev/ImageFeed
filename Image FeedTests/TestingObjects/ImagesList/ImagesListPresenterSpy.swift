//
//  ImagesListPresenterSpy.swift
//  Image FeedTests
//
//  Created by Михаил Бобылев on 06.07.2025.
//

import Image_Feed
import Foundation

final class ImagesListPresenterSpy: ImagesListPresenterProtocol {
    var view: ImagesListViewControllerProtocol?
    var photos: [Photo] = []
    var viewDidLoadCalled: Bool = false
    var fetchPhotosNextPageCalled = false
    
    func viewDidLoad() {
        viewDidLoadCalled = true
    }
    
    func fetchPhotosNextPage() {
        fetchPhotosNextPageCalled = true
    }
    
    func changeLike(on indexPath: IndexPath, _ cell: ImagesListCellProtocol) {
    }
}
