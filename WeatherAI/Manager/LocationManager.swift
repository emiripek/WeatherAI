//
//  LocationManager.swift
//  WeatherAI
//
//  Created by Emirhan İpek on 18.07.2024.
//

import CoreLocation
import Foundation
import UIKit

final class LocationManager: NSObject, CLLocationManagerDelegate {
    
    private let manager = CLLocationManager()
    
    static let shared = LocationManager()
    
    private var locationFetchCompletion: ((CLLocation) -> Void)?
    
    private var location: CLLocation? {
        didSet {
            guard let location else {
                return
            }
            locationFetchCompletion?(location)
        }
    }
    
    public func getCurrentLocation(completion: @escaping (CLLocation) -> Void) {
        self.locationFetchCompletion = completion
        manager.delegate = self
        manager.requestWhenInUseAuthorization()
    }
    
    private func showAlertToOpenSettings() {
        guard let topController = getTopViewController() else {
            return
        }
        
        let alert = UIAlertController(title: "Location Services Disabled",
                                      message: "Please enable location services in settings to use this feature.",
                                      preferredStyle: .alert)
        
        let openSettingsAction = UIAlertAction(title: "Open Settings", style: .default) { _ in
            guard let settingsUrl = URL(string: UIApplication.openSettingsURLString) else {
                return
            }
            
            if UIApplication.shared.canOpenURL(settingsUrl) {
                UIApplication.shared.open(settingsUrl, completionHandler: { _ in
                    // Handle if needed
                })
            }
        }
        
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        
        alert.addAction(openSettingsAction)
        alert.addAction(cancelAction)
        
        topController.present(alert, animated: true, completion: nil)
    }
    
    private func getTopViewController() -> UIViewController? {
        guard let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
              let window = windowScene.windows.first(where: { $0.isKeyWindow }) else {
            return nil
        }
        
        var topController = window.rootViewController
        while let presentedViewController = topController?.presentedViewController {
            topController = presentedViewController
        }
        return topController
    }
    
    // MARK: - Location
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let location = locations.first else {
            return
        }
        self.location = location
        manager.stopUpdatingLocation()
    }
    
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        switch status {
        case .authorizedWhenInUse, .authorizedAlways:
            manager.startUpdatingLocation()
        case .denied, .restricted:
            showAlertToOpenSettings()
        case .notDetermined:
            manager.requestWhenInUseAuthorization()
        @unknown default:
            break
        }
    }
}
