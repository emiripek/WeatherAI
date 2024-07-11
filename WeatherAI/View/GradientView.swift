//
//  GradientView.swift
//  WeatherAI
//
//  Created by Emirhan İpek on 11.07.2024.
//

import UIKit

class GradientView: UIView {
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupGradientLayer()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupGradientLayer()
    }
    
    private func setupGradientLayer() {
        let gradientLayer = CAGradientLayer()
        gradientLayer.frame = self.bounds
        gradientLayer.colors = [
            UIColor(red: 0.74, green: 0.91, blue: 1.00, alpha: 1.00).cgColor,
            UIColor(red: 1.00, green: 1.00, blue: 1.00, alpha: 1.00).cgColor
        ]
        gradientLayer.locations = [0.0, 1.0]
        self.layer.insertSublayer(gradientLayer, at: 0)
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        self.layer.sublayers?.first?.frame = self.bounds
    }
}
