//
//  City.swift
//  Weather+Combine
//
//  Created by Дмитрий Волынкин on 10.09.2023.
//

import Foundation

struct City: Identifiable {
    var id = UUID().uuidString
    var name: String
    var lat: Double
    var lon: Double
    var country: String
    var state: String = ""
    
    init(city: CityResponse) {
        name = city.name
        lat = city.lat
        lon = city.lon
        country = city.country
        state = city.state ?? ""
    }
    
    init(description: String) {
        let parts = description.split(separator: ",")
        
        id =  String(parts[0])
        name = String(parts[1])
        lat = Double(parts[2])!
        lon = Double(parts[3])!
        country = String(parts[4])
        
        if parts.count == 6 {
            state = String(parts[5])
        }
    }
    
    /// Turn this struct into one comma-delimited string
    var description: String {
        "\(id),\(name),\(lat),\(lon),\(country),\(state)"
    }
}

