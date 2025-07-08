//
//  ImagesListCellMock.swift
//  Image FeedTests
//
//  Created by Михаил Бобылев on 06.07.2025.
//

import Image_Feed
import UIKit

final class ImagesListCellMock: UITableViewCell, ImagesListCellProtocol {
    var likeSet: Bool?
    
    func setIsLiked(isLiked: Bool) {
        likeSet = isLiked
    }
    
    func makeGradientLayer() {
        
    }
    
    func removeGradientLayer() {
        
    }
}
