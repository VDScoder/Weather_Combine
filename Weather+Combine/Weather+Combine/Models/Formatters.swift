//
//  Formatters.swift
//  Weather+Combine
//
//  Created by Дмитрий Волынкин on 10.09.2023.
//

import Foundation


class Formatters {
    class func getDate(unixTime: Double) -> String {
        let date = Date(timeIntervalSince1970: unixTime)
        let dateFormatter = DateFormatter()
        dateFormatter.dateStyle = DateFormatter.Style.medium
        dateFormatter.timeZone = .autoupdatingCurrent
        return dateFormatter.string(from: date)
    }
    
    class func getTime(unixTime: Double) -> String {
        let date = Date(timeIntervalSince1970: unixTime)
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "h a"
        dateFormatter.timeZone = .current
        return dateFormatter.string(from: date)
    }
}
