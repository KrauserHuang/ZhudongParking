//
//  Date+Extension.swift
//  ZhudongParking
//
//  Created by Tai Chin Huang on 2022/8/26.
//

import Foundation

extension Date {
    func longDate() -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd"
        return dateFormatter.string(from: self)
    }
}
