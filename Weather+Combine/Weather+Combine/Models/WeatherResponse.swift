//
//  WeatherResponse.swift
//  Weather+Combine
//
//  Created by Дмитрий Волынкин on 10.09.2023.
//

import Foundation

struct WeatherResponse: Decodable {
    var current: Current
    var hourly: [Current]
}

struct Current: Decodable {
    let dt: Double
    let temp: Double
    let feels_like: Double
    let clouds: Int
    let wind_speed: Double 
    let weather: [Weather]
}

struct Weather: Decodable {
    let main: String
    let description: String
}
