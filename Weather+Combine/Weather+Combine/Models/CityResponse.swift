//
//  CityResponse.swift
//  Weather+Combine
//
//  Created by Дмитрий Волынкин on 10.09.2023.
//

import Foundation

struct CityResponse: Decodable {
    var name: String
    var lat: Double
    var lon: Double
    var country: String
    var state: String? = ""
}
