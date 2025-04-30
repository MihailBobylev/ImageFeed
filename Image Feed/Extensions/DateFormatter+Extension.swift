//
//  DateFormatter+Extension.swift
//  Image Feed
//
//  Created by Михаил Бобылев on 30.04.2025.
//

import Foundation

extension DateFormatter {
    static let longStyle: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateStyle = .long
        formatter.timeStyle = .none
        return formatter
    }()
}
