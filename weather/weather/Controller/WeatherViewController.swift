//
//  ViewController.swift
//  weather
//
//  Created by Artyom Burkan on 14.05.2020.
//  Copyright © 2020 Artyom Burkan. All rights reserved.
//

import UIKit
import CoreLocation

class WeatherViewController: UIViewController {
    
    @IBOutlet private weak var searchTextField: UITextField!
    @IBOutlet private weak var cityLabel: UILabel!
    @IBOutlet private weak var weatherImageView: UIImageView!
    @IBOutlet private weak var temperatureLabel: UILabel!
    
    private let weatherFetcher = WeatherFetcher()
    private let locationManager = CLLocationManager()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        locationManager.delegate = self
        locationManager.requestWhenInUseAuthorization()
        locationManager.requestLocation()
        
        searchTextField.delegate = self
    }
    
    @IBAction private func searchPressed(_ sender: UIButton) {
        searchTextField.endEditing(true)
    }
    
    @IBAction private func locationPressed(_ sender: UIButton) {
        locationManager.requestLocation()
    }

    private var updateUI: (Result<Weather, RequestError>) -> Void {
        return { responseData in
            switch responseData {
            case .success(let weather):
                DispatchQueue.main.async {
                    self.searchTextField.text?.removeAll()
                    self.cityLabel.text = weather.name
                    self.temperatureLabel.text = weather.temperature
                    self.weatherImageView.image = UIImage(systemName: weather.weatherIconName)
                }
            case .failure(let error):
                print("Error of weather request: \(error)")
            }
        }
    }
}

// MARK: - UITextFieldDelegate

extension WeatherViewController: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        
        if let city = textField.text {
            weatherFetcher.fetchByCityName(at: city, responseDataHandler: updateUI)
        }
        
        return true
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        if let city = textField.text {
           weatherFetcher.fetchByCityName(at: city, responseDataHandler: updateUI)
        }
    }
}

// MARK: - CLLocationManagerDelegate

extension WeatherViewController: CLLocationManagerDelegate {
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        if let location = locations.last {
            locationManager.stopUpdatingLocation()
            
            let lat = String(location.coordinate.latitude)
            let lon = String(location.coordinate.longitude)
            
            weatherFetcher.fetchByGeographicCoordinates(latitude: lat, longitude: lon, responseDataHandler: updateUI)
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print(error)
    }
}
