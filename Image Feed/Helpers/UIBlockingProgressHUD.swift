//
//  UIBlockingProgressHUD.swift
//  Image Feed
//
//  Created by Михаил Бобылев on 31.05.2025.
//

import UIKit
import ProgressHUD

final class UIBlockingProgressHUD {
    
    private static var window: UIWindow? {
        return UIApplication.shared.windows.first
    }

    static func show() {
        window?.isUserInteractionEnabled = false
        ProgressHUD.mediaSize = 51
        ProgressHUD.marginSize = 13
        ProgressHUD.animate()
    }
    
    static func dismiss() {
        window?.isUserInteractionEnabled = true
        ProgressHUD.dismiss()
    }
}
