//
//  SearchViewModel.swift
//  Weather+Combine
//
//  Created by Дмитрий Волынкин on 10.09.2023.
//

import Foundation
import Combine

class SearchViewModel: ObservableObject {
    @Published var city = ""
    @Published var cities = [City]()
    private var cancellable: AnyCancellable?
    
    init() {
        cancellable = $city
            .debounce(for: 0.3, scheduler: RunLoop.main)
            .dropFirst()
            .map { city -> String in
                if city.isEmpty || city.count < 3 {
                    return "xyz"
                } else {
                    return city.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)!
                }
            }
            .map { encodedCity -> URL in
                let urlString = "https://api.openweathermap.org/geo/1.0/direct?q=\(encodedCity)&limit=30&appid=\(AppKeyViewModel.apiKey)"
                return URL(string: urlString)!
            }
            .map { cityUrl -> AnyPublisher<[City], Never> in
                URLSession.shared.dataTaskPublisher(for: cityUrl)
                    .map { (data: Data, response: URLResponse) in
                        data
                    }
                    .decode(type: [CityResponse].self, decoder: JSONDecoder())
                    .map { cityResponses in
                        cityResponses.map { cityResponse in
                            City(city: cityResponse)
                        }
                    }
                    .catch({ error in
                        Just([ City(city: CityResponse(name: error.localizedDescription, lat: 0.0, lon: 0.0, country: "")) ])
                    })
                    .eraseToAnyPublisher()
            }
            .switchToLatest()
            .receive(on: RunLoop.main)
            .sink { [unowned self] (items) in
                cities.removeAll()

                cities = items
            }
    }
}

