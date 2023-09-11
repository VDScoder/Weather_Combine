//
//  WeatherToView.swift
//  Weather+Combine
//
//  Created by Дмитрий Волынкин on 10.09.2023.
//

import Foundation

import SwiftUI

struct WeatherToView: Identifiable {
    var id: Int = 0
    var city = City(city: CityResponse(name: "", lat: 0, lon: 0, country: ""))
    var currentWeather = CurrentWeather()
    var hourly: [CurrentWeather] = []
    
    init() { }
    
    init(id: Int, city: City, error: String) {
        self.id = id
        self.city = city
        currentWeather = CurrentWeather(date: "", temp: "", feelsLike: "", clouds: "", windSpeed: "", simpleDescription: "", description: error)
    }
    
    init(id: Int, city: City, weather: WeatherResponse) {
        self.id = id
        self.city = city
        currentWeather = getCurrentWeather(weather: weather.current, getDate: true)
        
        hourly = weather.hourly.map {
            getCurrentWeather(weather: $0, getDate: false)
        }
    }
    
    func getCurrentWeather(weather: Current, getDate: Bool = false) -> CurrentWeather {
        var currentWeather = CurrentWeather()
        currentWeather.date = getDate ? Formatters.getDate(unixTime: weather.dt) : Formatters.getTime(unixTime: weather.dt)
        currentWeather.temp = "\(Int(weather.temp))"
        currentWeather.feelsLike = "\(Int(weather.feels_like))"
        currentWeather.clouds = "\(weather.clouds)%"
        currentWeather.windSpeed = "\(Int(weather.wind_speed)) mph"
        currentWeather.simpleDescription = weather.weather[0].main
        currentWeather.description = weather.weather[0].description
        
        return currentWeather
    }
}

struct CurrentWeather: Identifiable {
    let id = UUID()
    var date = ""
    var temp = ""
    var feelsLike = ""
    var clouds = ""
    var windSpeed = ""
    var simpleDescription = "atmosphere"
    var description = ""
    var image: Image {
        switch simpleDescription {
        case "Thunderstorm":
            return Image(systemName: "cloud.bolt")
        case "Drizzle":
            return Image(systemName: "cloud.drizzle")
        case "Rain":
            return Image(systemName: "cloud.rain")
        case "Snow":
            return Image(systemName: "cloud.snow")
        case "Clear":
            return Image(systemName: "sun.max")
        case "Clouds":
            return Image(systemName: "cloud")
        default:
            return Image(systemName: "tornado")
        }
    }
}

