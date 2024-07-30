//
//  NetworkManager.swift
//  WeatherAI
//
//  Created by Emirhan İpek on 13.07.2024.
//

import Foundation
import CoreData

class NetworkManager {
    static let shared = NetworkManager()
    private init() {}
    
    func fetchWeatherData(latitude: Double, longitude: Double, completion: @escaping (Result<WeatherResponse, Error>) -> Void) {
        let urlString = "https://api.openweathermap.org/data/2.5/weather?lat=\(latitude)&lon=\(longitude)&appid=0c7ab8828869b4c4f6245a2a1e3a4907&units=metric"
        guard let url = URL(string: urlString) else { return }
        
        let task = URLSession.shared.dataTask(with: url) { data, response, error in
            if let error = error {
                completion(.failure(error))
                return
            }
            
            guard let data = data else {
                completion(.failure(NSError(domain: "dataNilError", code: -10001, userInfo: nil)))
                return
            }
            
            do {
                let weatherResponse = try JSONDecoder().decode(WeatherResponse.self, from: data)
                
                if let icon = weatherResponse.weather.first?.icon, let iconURL = URL(string: "https://openweathermap.org/img/wn/\(icon)@4x.png") {
                    self.downloadIconData(from: iconURL) { result in
                        switch result {
                        case .success(let iconData):
                            CoreDataManager.shared.saveWeatherData(weather: weatherResponse, iconData: iconData)
                            completion(.success(weatherResponse))
                        case .failure(let error):
                            print("Failed to download icon data: \(error)")
                            CoreDataManager.shared.saveWeatherData(weather: weatherResponse, iconData: nil)
                            completion(.success(weatherResponse))
                        }
                    }
                } else {
                    CoreDataManager.shared.saveWeatherData(weather: weatherResponse, iconData: nil)
                    completion(.success(weatherResponse))
                }
            } catch {
                completion(.failure(error))
            }
        }
        
        task.resume()
    }
    
    func fetchForecastData(latitude: Double, longitude: Double, completion: @escaping (Result<WeatherForecastResponse, Error>) -> Void) {
        let urlString = "https://api.openweathermap.org/data/2.5/forecast?lat=\(latitude)&lon=\(longitude)&appid=0c7ab8828869b4c4f6245a2a1e3a4907&units=metric"
        guard let url = URL(string: urlString) else { return }
        
        let task = URLSession.shared.dataTask(with: url) { data, response, error in
            if let error = error {
                completion(.failure(error))
                return
            }
            
            guard let data = data else {
                completion(.failure(NSError(domain: "dataNilError", code: -10001, userInfo: nil)))
                return
            }
            
            do {
                let forecastResponse = try JSONDecoder().decode(WeatherForecastResponse.self, from: data)
                CoreDataManager.shared.saveForecastData(forecastResponse)
                
                completion(.success(forecastResponse))
            } catch {
                completion(.failure(error))
            }
        }
        
        task.resume()
    }
    
    private func downloadIconData(from url: URL, completion: @escaping (Result<Data, Error>) -> Void) {
        let task = URLSession.shared.dataTask(with: url) { data, response, error in
            if let error = error {
                completion(.failure(error))
                return
            }
            
            guard let data = data else {
                completion(.failure(NSError(domain: "dataNilError", code: -10001, userInfo: nil)))
                return
            }
            
            completion(.success(data))
        }
        
        task.resume()
    }
}

