//
//  String+Ext..swift
//  WeatherAI
//
//  Created by Emirhan İpek on 13.07.2024.
//

import Foundation

extension String {
    func capitalizedWords() -> String {
        return self.lowercased().split(separator: " ").map { $0.capitalized }.joined(separator: " ")
    }
}
