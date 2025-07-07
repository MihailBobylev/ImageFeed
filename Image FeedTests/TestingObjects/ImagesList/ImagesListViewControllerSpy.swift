//
//  ImagesListViewControllerSpy.swift
//  Image FeedTests
//
//  Created by Михаил Бобылев on 06.07.2025.
//

import Image_Feed

final class ImagesListViewControllerSpy: ImagesListViewControllerProtocol {
    var presenter: ImagesListPresenterProtocol?
    
    //var likedPhoto: (isLiked: Bool, cell: ImagesListCell)?
    var didUpdateTableView = false
    var didShowLikeError = false
    
    func configure(_ presenter: ImagesListPresenterProtocol) {
        
    }
    
    func updateTableViewAnimated(oldCount: Int, newCount: Int) {
        didUpdateTableView = true
    }
    
    func setIsLiked(isLiked: Bool, on cell: ImagesListCellProtocol) {
        
    }
    
    func showChangeLikeError() {
        didShowLikeError = true
    }
}
