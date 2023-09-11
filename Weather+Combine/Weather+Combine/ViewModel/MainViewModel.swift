//
//  MainViewModel.swift
//  Weather+Combine
//
//  Created by Дмитрий Волынкин on 10.09.2023.
//

import SwiftUI
import Combine

class MainViewModel: ObservableObject {
    @AppStorage("locations") var locations: String = ""
    @AppStorage("units") var isFahrenheit: Bool = false
    @Published var id = UUID().uuidString
    @Published var weatherForCities: [WeatherToView] = []
    @Published var fetchingWeather = false
    
    @Published var cities: [City] = []
    
    @Published var isAddingCity = false
    @Published var dismissView = false
    
    private var updateWeatherPipeline: AnyCancellable?
    private var updateUnitsPipeline: AnyCancellable?
    
    func updateAllCityWeather() {
        if locations.isEmpty { return }
        
        fetchingWeather = true
        var index = -1
        weatherForCities.removeAll()
        cities = populateCities(from: locations)
        
        updateWeatherPipeline = cities.publisher
            .map { city -> (City, URL) in
                
                let units = isFahrenheit ? "imperial" : "metric"
                let urlString = "https://api.openweathermap.org/data/2.5/onecall?lat=\(city.lat)&lon=\(city.lon)&exclude=minutely,daily,alerts&units=\(units)&appid=\(AppKeyViewModel.apiKey)"
                return (city, URL(string: urlString)!)
            }
            .flatMap(maxPublishers: .max(1)) { (city, url) in
                URLSession.shared.dataTaskPublisher(for: url)
                    .map { (data: Data, response: URLResponse) in
                        data
                    }
                    .decode(type: WeatherResponse.self, decoder: JSONDecoder())
                    .map { weatherResponse -> WeatherToView in
                        index+=1
                        return WeatherToView(id: index, city: city, weather: weatherResponse)
                    }
                    .catch { error -> Just<WeatherToView> in
                        index+=1
                        return Just(WeatherToView(id: index, city: city, error: error.localizedDescription))
                    }
            }
            .receive(on: RunLoop.main)
            .sink { [unowned self] (weather) in
                weatherForCities.append(weather)
                fetchingWeather = false
            }
    }
    
    func populateCities(from locations: String) -> [City] {
        let cityStrings = locations.split(separator: "|")
        
        return cityStrings.map { cityString in
            City(description: String(cityString))
        }
    }
    
    
    func addCity(city: City) {
        if locations.isEmpty {
            locations = city.description
        } else {
            locations = locations + "|" + city.description
        }
        
        cities = populateCities(from: locations)
        
        let index = cities.count - 1
        
        let units = isFahrenheit ? "imperial" : "metric"
        let urlString = "https://api.openweathermap.org/data/2.5/onecall?lat=\(city.lat)&lon=\(city.lon)&exclude=minutely,daily,alerts&units=\(units)&appid=\(AppKeyViewModel.apiKey)"
        let url = URL(string: urlString)!
        
        updateWeatherPipeline = URLSession.shared.dataTaskPublisher(for: url)
            .map { (data: Data, response: URLResponse) in
                data
            }
            .decode(type: WeatherResponse.self, decoder: JSONDecoder())
            .map { weatherResponse -> WeatherToView in
                return WeatherToView(id: index, city: city, weather: weatherResponse)
            }
            .catch { error -> Just<WeatherToView> in
                return Just(WeatherToView(id: index, city: city, error: error.localizedDescription))
            }
            .receive(on: RunLoop.main)
            .sink { [unowned self] (weather) in
                weatherForCities.append(weather)
                isAddingCity = false
                dismissView = true
            }
    }
    
    func deleteCity(cityToDelete: City) {
        
        if let index = cities.firstIndex(where: { $0.id == cityToDelete.id }) {
            cities.remove(at: index)
        }
        
        let cityStringArray = cities.map { city in
            city.description
        }
        
        locations = cityStringArray.joined(separator: "|")
        
        if let index = weatherForCities.firstIndex(where: { $0.city.id == cityToDelete.id }) {
            weatherForCities.remove(at: index)
            
            var index = 0
            for i in weatherForCities.indices {
                weatherForCities[i].id = index
                index += 1
            }
            
            id = UUID().uuidString 
        }
    }
}

class MockMainViewModel: MainViewModel {
    
    override init() {
        super.init()
        updateAllCityWeather()
    }
    
    override func updateAllCityWeather() {
        weatherForCities.removeAll()
        
        let city1 = City(description: "1,Moscow,10.0,23.0,RU")
        let weatherResponse1 = WeatherResponse(current: Current(dt: 7,
                                                                temp: 77,
                                                                feels_like: 76,
                                                                clouds: 1,
                                                                wind_speed: 11,
                                                                weather: [Weather(main: "Rain", description: "overcast clouds")]),
                                               hourly: [Current(dt: 1618317040,
                                                                temp: 77,
                                                                feels_like: 76,
                                                                clouds: 1,
                                                                wind_speed: 11,
                                                                weather: [Weather(main: "Clouds", description: "overcast clouds")]),
                                                        Current(dt: 1618317040,
                                                                temp: 80,
                                                                feels_like: 82,
                                                                clouds: 12,
                                                                wind_speed: 20,
                                                                weather: [Weather(main: "Rain", description: "shower rain")])])

        let city2 = City(description: "1,Tomsk,10.0,23.0,RU")
        let weatherResponse2 = WeatherResponse(current: Current(dt: 1618317040,
                                                                temp: 88,
                                                                feels_like: 91,
                                                                clouds: 21,
                                                                wind_speed: 15,
                                                                weather: [Weather(main: "Clear", description: "clear sky")]),
                                               hourly: [Current(dt: 1618317040,
                                                                temp: 92,
                                                                feels_like: 94,
                                                                clouds: 22,
                                                                wind_speed: 16,
                                                                weather: [Weather(main: "Clear", description: "clear sky")])])
        self.weatherForCities = [WeatherToView(id: 0, city: city1, weather: weatherResponse1),
                                 WeatherToView(id: 1, city: city2, weather: weatherResponse2)]
    }
}

