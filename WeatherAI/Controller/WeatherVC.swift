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
    
    // MARK: - Dummy Data for collection view
    let times = ["9AM", "10AM", "11AM", "12PM", "1PM"]
    let temperatures = ["18°", "19°", "24°", "25°", "26°"]
    let weatherIcons = ["01_sunny_color", "03_cloud_color", "04_sun_cloudy_color", "09_light_rain_color", "38_blowing_sand_color"]
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupCollectionViewLayout()
        configureWeatherCollectionView()
    }
    
    func configureWeatherCollectionView() {
        weatherCollectionView.dataSource = self
        weatherCollectionView.delegate = self
        weatherCollectionView.backgroundColor = .clear
    }
}

extension WeatherVC: UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return times.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "WeatherCollectionViewCell", for: indexPath) as! WeatherCollectionViewCell
        cell.timeLabel.text = times[indexPath.item]
        cell.hourlyTemperatureLabel.text = temperatures[indexPath.item]
        cell.weatherImageView.image = UIImage(named: weatherIcons[indexPath.item])
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: 80, height: 120)
    }
    
    func setupCollectionViewLayout() {
        if let layout = weatherCollectionView.collectionViewLayout as? UICollectionViewFlowLayout {
            layout.minimumLineSpacing = 10
            layout.minimumInteritemSpacing = 10
            layout.sectionInset = UIEdgeInsets(top: 10, left: 10, bottom: 10, right: 10)
        }
    }
}



