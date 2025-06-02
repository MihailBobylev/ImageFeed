//
//  AlertPresenter.swift
//  Image Feed
//
//  Created by Михаил Бобылев on 01.06.2025.
//

import UIKit

final class AlertPresenter {
    static func showNetworkError(in viewController: UIViewController) {
        let alert = UIAlertController(
            title: "Что-то пошло не так",
            message: "Не удалось войти в систему",
            preferredStyle: .alert)
        
        let okAction = UIAlertAction(title: "Ок", style: .default) { _ in }
        
        alert.addAction(okAction)
        viewController.present(alert, animated: true, completion: nil)
    }
}
