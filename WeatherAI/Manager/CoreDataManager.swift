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
}
