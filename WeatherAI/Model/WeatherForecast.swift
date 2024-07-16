//
//  WeatherForecast.swift
//  WeatherAI
//
//  Created by Emirhan İpek on 15.07.2024.
//

import Foundation

struct WeatherForecastResponse: Codable {
    let list: [Forecast]
    let city: City
    
    struct Forecast: Codable {
        let dt: TimeInterval
        let main: Main
        let weather: [Weather]
        let clouds: Clouds
        let wind: Wind
        let visibility: Int
        let pop: Double
        let rain: Rain?
        let sys: Sys
        let dt_txt: String
        
        struct Main: Codable {
            let temp: Double
            let feels_like: Double
            let temp_min: Double
            let temp_max: Double
            let pressure: Int
            let sea_level: Int
            let grnd_level: Int
            let humidity: Int
            let temp_kf: Double
        }
        
        struct Weather: Codable {
            let id: Int
            let main: String
            let description: String
            let icon: String
        }
        
        struct Clouds: Codable {
            let all: Int
        }
        
        struct Wind: Codable {
            let speed: Double
            let deg: Int
            let gust: Double
        }
        
        struct Rain: Codable {
            let threeHour: Double?
            
            enum CodingKeys: String, CodingKey {
                case threeHour = "3h"
            }
        }
        
        struct Sys: Codable {
            let pod: String
        }
        
        func formattedTime() -> String {
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "ha"
            let date = Date(timeIntervalSince1970: self.dt)
            return dateFormatter.string(from: date)
        }
        
        func formattedTemperature() -> String {
            return "\(Int(self.main.temp))°"
        }
    }
    
    struct City: Codable {
        let id: Int
        let name: String
        let coord: Coord
        let country: String
        let population: Int
        let timezone: Int
        let sunrise: TimeInterval
        let sunset: TimeInterval
        
        struct Coord: Codable {
            let lat: Double
            let lon: Double
        }
    }
}
