//
//  WeatherVC.swift
//  WeatherAI
//
//  Created by Emirhan İpek on 11.07.2024.
//

import UIKit

class WeatherVC: UIViewController {
    
    @IBOutlet weak var cityNameLabel: UILabel!
    @IBOutlet weak var weatherIconImageView: UIImageView!
    @IBOutlet weak var weatherLabel: UILabel!
    @IBOutlet weak var temperatureLabel: UILabel!
    @IBOutlet weak var weatherCollectionView: UICollectionView!
    @IBOutlet weak var noInternetView: UIView!
    
    var forecastData: [WeatherForecastResponse.Forecast] = []
    var forecastEntities: [ForecastEntity] = []
    var latitude: Double = 41.0082
    var longitude: Double = 28.9784
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configureWeatherCollectionView()
        getLocation()
    }
    
    func getLocation() {
        LocationManager.shared.getCurrentLocation { location in
            self.latitude = location.coordinate.latitude
            self.longitude = location.coordinate.longitude
            self.fetchWeatherData(latitude: self.latitude, longitude: self.longitude)
            self.fetchForecastData(latitude: self.latitude, longitude: self.longitude)
        }
    }
    
    func configureWeatherCollectionView() {
        //        weatherCollectionView.isHidden = false
        weatherCollectionView.dataSource = self
        weatherCollectionView.delegate = self
        weatherCollectionView.backgroundColor = .clear
        setupCollectionViewLayout()
    }
    
    func setupCollectionViewLayout() {
        if let layout = weatherCollectionView.collectionViewLayout as? UICollectionViewFlowLayout {
            layout.minimumLineSpacing = 10
            layout.minimumInteritemSpacing = 10
            layout.sectionInset = UIEdgeInsets(top: 10, left: 10, bottom: 10, right: 10)
        }
    }
    
    func fetchWeatherData(latitude: Double, longitude: Double) {
        guard Reachability.isConnectedToNetwork() else {
            fetchWeatherDataFromCoreData()
            //            weatherCollectionView.isHidden = true
            //            noInternetView.isHidden = false
            return
        }
        
        NetworkManager.shared.fetchWeatherData(latitude: latitude, longitude: longitude) { result in
            switch result {
            case .success(let weatherResponse):
                DispatchQueue.main.async {
                    self.updateUI(with: weatherResponse)
                }
                self.saveWeatherDataToCoreData(weatherResponse)
            case .failure(let error):
                print("Failed to fetch weather data: \(error)")
                self.fetchWeatherDataFromCoreData()
            }
        }
    }
    
    func fetchForecastData(latitude: Double, longitude: Double) {
        guard Reachability.isConnectedToNetwork() else {
            fetchForecastDataFromCoreData()
            return
        }
        
        NetworkManager.shared.fetchForecastData(latitude: latitude, longitude: longitude) { result in
            switch result {
            case .success(let forecastResponse):
                DispatchQueue.main.async {
                    self.cityNameLabel.text = forecastResponse.city.name
                    self.forecastData = forecastResponse.list
                    self.weatherCollectionView.reloadData()
                }
                // Forecast verisini Core Data'ya kaydet
                self.saveForecastDataToCoreData(forecastResponse)
            case .failure(let error):
                print("Failed to fetch forecast data: \(error)")
                self.fetchForecastDataFromCoreData()
            }
        }
    }
    
    func updateUI(with weatherResponse: WeatherResponse) {
        cityNameLabel.text = weatherResponse.name
        let temperatureInt = Int(weatherResponse.main.temp)
        temperatureLabel.text = "\(temperatureInt)°"
        weatherLabel.text = weatherResponse.weather.first?.description.capitalizedWords()
        
        if let icon = weatherResponse.weather.first?.icon {
            let iconURL = URL(string: "https://openweathermap.org/img/wn/\(icon)@4x.png")
            loadImage(from: iconURL)
        }
    }
    
    func loadImage(from url: URL?) {
        guard let url = url else { return }
        
        DispatchQueue.global().async {
            if let data = try? Data(contentsOf: url), let image = UIImage(data: data) {
                DispatchQueue.main.async {
                    self.weatherIconImageView.image = image
                }
            }
        }
    }
    
    func fetchWeatherDataFromCoreData() {
        if let weatherEntity = CoreDataManager.shared.fetchLatestWeatherData() {
            DispatchQueue.main.async {
                self.cityNameLabel.text = weatherEntity.city
                self.temperatureLabel.text = "\(Int(weatherEntity.temp))°"
                self.weatherLabel.text = weatherEntity.weatherDescription
                
                if let iconData = weatherEntity.iconData, let image = UIImage(data: iconData) {
                    self.weatherIconImageView.image = image
                }
            }
        }
    }
    
    func fetchForecastDataFromCoreData() {
        forecastEntities = CoreDataManager.shared.fetchForecastDataFromCoreData()
        DispatchQueue.main.async {
            self.weatherCollectionView.reloadData()
        }
    }
    
    func saveWeatherDataToCoreData(_ weatherResponse: WeatherResponse) {
        guard let icon = weatherResponse.weather.first?.icon else { return }
        let iconURL = URL(string: "https://openweathermap.org/img/wn/\(icon)@4x.png")
        
        if let iconURL = iconURL, let iconData = try? Data(contentsOf: iconURL) {
            CoreDataManager.shared.saveWeatherData(weather: weatherResponse, iconData: iconData)
        } else {
            CoreDataManager.shared.saveWeatherData(weather: weatherResponse, iconData: nil)
        }
    }
    
    func saveForecastDataToCoreData(_ forecastResponse: WeatherForecastResponse) {
        CoreDataManager.shared.saveForecastData(forecastResponse)
    }
}

extension WeatherVC: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if Reachability.isConnectedToNetwork() {
            return forecastData.count
        } else {
            return forecastEntities.count
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: WeatherCollectionViewCell.identifier, for: indexPath) as! WeatherCollectionViewCell
        
        if Reachability.isConnectedToNetwork() {
            cell.populate(forecast: forecastData[indexPath.row])
        } else {
            cell.populate(forecastEntity: forecastEntities[indexPath.row])
        }
        
        return cell
    }
}

extension WeatherVC: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: 80, height: 120)
    }
}



