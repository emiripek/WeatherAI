//
//  CoreDataManager.swift
//  WeatherAI
//
//  Created by Emirhan İpek on 20.07.2024.
//

import CoreData

class CoreDataManager {
    static let shared = CoreDataManager()
    
    let persistentContainer: NSPersistentContainer = {
        let container = NSPersistentContainer(name: "WeatherCoreData")
        container.loadPersistentStores { (storeDescription, error) in
            if let error = error as NSError? {
                fatalError("Unresolved error \(error), \(error.userInfo)")
            }
        }
        return container
    }()
    
    var context: NSManagedObjectContext {
        return persistentContainer.viewContext
    }
    
    func saveWeatherData(weather: WeatherResponse, iconData: Data?) {
        let weatherEntity = WeatherEntity(context: context)
        
        weatherEntity.city = weather.name
        weatherEntity.temp = weather.main.temp
        weatherEntity.weatherDescription = weather.weather.first?.description
        weatherEntity.iconData = iconData
        weatherEntity.timestamp = Date()
        
        do {
            try context.save()
        } catch {
            print("Failed to save weather data: \(error)")
        }
    }
    
    func saveForecastData(_ forecastResponse: WeatherForecastResponse) {
        clearForecastData()
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
        
        let timeFormatter = DateFormatter()
        timeFormatter.dateFormat = "ha"
        
        for forecast in forecastResponse.list {
            let forecastEntity = ForecastEntity(context: context)
            
            if let date = dateFormatter.date(from: forecast.dt_txt) {
                let formattedTime = timeFormatter.string(from: date)
                forecastEntity.date = formattedTime
            } else {
                print("Geçersiz tarih formatı: \(forecast.dt_txt)")
            }
            
            forecastEntity.temperature = forecast.main.temp
            forecastEntity.icon = forecast.weather.first?.icon
            forecastEntity.weatherDescription = forecast.weather.first?.description
            
            if let icon = forecast.weather.first?.icon,
               let iconURL = URL(string: "https://openweathermap.org/img/wn/\(icon)@2x.png"),
               let iconData = try? Data(contentsOf: iconURL) {
                forecastEntity.iconData = iconData
            }
        }
        
        do {
            try context.save()
        } catch {
            print("Failed to save forecast data: \(error)")
        }
    }
    
    private func clearForecastData() {
        let fetchRequest: NSFetchRequest<NSFetchRequestResult> = ForecastEntity.fetchRequest()
        let deleteRequest = NSBatchDeleteRequest(fetchRequest: fetchRequest)
        
        do {
            try context.execute(deleteRequest)
        } catch {
            print("Failed to clear forecast data: \(error)")
        }
    }
    
    func fetchLatestWeatherData() -> WeatherEntity? {
        let fetchRequest: NSFetchRequest<WeatherEntity> = WeatherEntity.fetchRequest()
        fetchRequest.sortDescriptors = [NSSortDescriptor(key: "timestamp", ascending: false)]
        fetchRequest.fetchLimit = 1
        
        do {
            let result = try context.fetch(fetchRequest)
            return result.first
        } catch {
            print("Failed to fetch weather data: \(error)")
            return nil
        }
    }
    
    func fetchForecastDataFromCoreData() -> [ForecastEntity] {
        let fetchRequest: NSFetchRequest<ForecastEntity> = ForecastEntity.fetchRequest()
        fetchRequest.sortDescriptors = [NSSortDescriptor(key: "date", ascending: true)]
        
        do {
            let forecasts = try context.fetch(fetchRequest)
            return forecasts
        } catch {
            print("Failed to fetch forecast data: \(error)")
            return []
        }
    }
}
