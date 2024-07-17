//
//  WeatherCollectionViewCell.swift
//  WeatherAI
//
//  Created by Emirhan İpek on 12.07.2024.
//

import UIKit

final class WeatherCollectionViewCell: UICollectionViewCell {
    
    @IBOutlet weak var timeLabel: UILabel!
    @IBOutlet weak var weatherImageView: UIImageView!
    @IBOutlet weak var hourlyTemperatureLabel: UILabel!
    
    func populate(forecast: WeatherForecastResponse.Forecast) {
        self.timeLabel.text = forecast.formattedTime()
        self.hourlyTemperatureLabel.text = forecast.formattedTemperature()
        if let icon = forecast.weather.first?.icon {
            loadImage(from: icon)
        }
    }

    private func loadImage(from icon: String) {
        guard let iconURL = URL(string: "https://openweathermap.org/img/wn/\(icon)@2x.png") else {
            return
        }

        DispatchQueue.global().async {
            if let data = try? Data(contentsOf: iconURL), let image = UIImage(data: data) {
                DispatchQueue.main.async {
                    self.weatherImageView.image = image
                }
            }
        }
    }
}
