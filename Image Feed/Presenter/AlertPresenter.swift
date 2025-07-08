//
//  AlertPresenter.swift
//  Image Feed
//
//  Created by Михаил Бобылев on 01.06.2025.
//

import UIKit

public protocol AlertPresenterProtocol {
    static func showNetworkError(in viewController: UIViewController)
    static func showChangeLikeError(in viewController: UIViewController)
    static func showSingleImageLoadError(in viewController: UIViewController, completion: @escaping () -> Void)
    static func showLogoutAlert(in viewController: UIViewController, completion: @escaping () -> Void)
}

final class AlertPresenter: AlertPresenterProtocol {
    static func showNetworkError(in viewController: UIViewController) {
        let alert = UIAlertController(
            title: "Что-то пошло не так",
            message: "Не удалось войти в систему",
            preferredStyle: .alert)
        
        let okAction = UIAlertAction(title: "Ок", style: .default) { _ in }
        
        alert.addAction(okAction)
        viewController.present(alert, animated: true, completion: nil)
    }
    
    static func showChangeLikeError(in viewController: UIViewController) {
        let alert = UIAlertController(
            title: "Что-то пошло не так",
            message: "Попробуйте снова",
            preferredStyle: .alert)
        
        let okAction = UIAlertAction(title: "Ок", style: .default) { _ in }
        
        alert.addAction(okAction)
        viewController.present(alert, animated: true, completion: nil)
    }
    
    static func showSingleImageLoadError(in viewController: UIViewController, completion: @escaping () -> Void) {
        let alert = UIAlertController(
            title: "Что-то пошло не так.",
            message: "Попробовать ещё раз?",
            preferredStyle: .alert)
        
        let cancelAction = UIAlertAction(title: "Не надо", style: .cancel) { _ in }
        
        let retryAction = UIAlertAction(title: "Повторить", style: .default) { _ in
            completion()
        }
        
        alert.addAction(cancelAction)
        alert.addAction(retryAction)
        viewController.present(alert, animated: true)
    }
    
    static func showLogoutAlert(in viewController: UIViewController, completion: @escaping () -> Void) {
        let alert = UIAlertController(
            title: "Пока, пока!",
            message: "Уверены, что хотите выйти?",
            preferredStyle: .alert)
        
        let logoutAction = UIAlertAction(title: "Да", style: .default) { _ in
            completion()
        }
        
        let cancelAction = UIAlertAction(title: "Нет", style: .cancel) { _ in }
        
        alert.addAction(logoutAction)
        alert.addAction(cancelAction)
        
        viewController.present(alert, animated: true)
    }
}
