//
//  ImagesTableViewMock.swift
//  Image FeedTests
//
//  Created by Михаил Бобылев on 06.07.2025.
//

import UIKit

final class TableViewMock: UITableView {
    var insertedIndexPaths: [IndexPath] = []
    
    override func insertRows(at indexPaths: [IndexPath], with animation: UITableView.RowAnimation) {
        insertedIndexPaths.append(contentsOf: indexPaths)
    }

    override func performBatchUpdates(_ updates: (() -> Void)?, completion: ((Bool) -> Void)? = nil) {
        updates?()
        completion?(true)
    }
}
