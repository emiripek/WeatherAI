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
    
    var forecastData: [WeatherForecastResponse.Forecast] = []
    let latitude = 41.0082
    let longitude = 28.9784
    
    //    // MARK: - Dummy Data for collection view
    //    let times = ["9AM", "10AM", "11AM", "12PM", "1PM"]
    //    let temperatures = ["18°", "19°", "24°", "25°", "26°"]
    //    let weatherIcons = ["01_sunny_color", "03_cloud_color", "04_sun_cloudy_color", "09_light_rain_color", "38_blowing_sand_color"]
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configureWeatherCollectionView()
        fetchWeatherData(latitude: latitude, longitude: longitude)
        fetchForecastData(latitude: latitude, longitude: longitude)
    }
    
    func configureWeatherCollectionView() {
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
        NetworkManager.shared.fetchWeatherData(latitude: latitude, longitude: longitude) { result in
            switch result {
            case .success(let weatherResponse):
                DispatchQueue.main.async {
                    self.updateUI(with: weatherResponse)
                }
            case .failure(let error):
                print("Failed to fetch weather data: \(error)")
            }
        }
    }
    
    func fetchForecastData(latitude: Double, longitude: Double) {
        NetworkManager.shared.fetchForecastData(latitude: latitude, longitude: longitude) { result in
            switch result {
            case .success(let forecastResponse):
                DispatchQueue.main.async {
                    self.cityNameLabel.text = forecastResponse.city.name
                    self.forecastData = forecastResponse.list
                    self.weatherCollectionView.reloadData()
                }
            case .failure(let error):
                print("Failed to fetch forecast data: \(error)")
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
}

extension WeatherVC: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return forecastData.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: WeatherCollectionViewCell.identifier, for: indexPath) as! WeatherCollectionViewCell
        cell.populate(forecast: forecastData[indexPath.row])
        return cell
    }
}

extension WeatherVC: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: 80, height: 120)
    }
}



