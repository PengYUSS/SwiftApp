//
//  ViewController.swift
//  WeatherApp
//
//  Created by esirem on 24/11/2017.
//  Copyright © 2017 Apple Inc. All rights reserved.
//

import UIKit
import CoreLocation
import Alamofire


class ViewController: UIViewController, CLLocationManagerDelegate {
    //locationManger : nom, CLLocationManager : type
    let locationManger:CLLocationManager = CLLocationManager()
    var jsonResult: NSDictionary = [:]
    
    @IBOutlet weak var location: UILabel!
    @IBOutlet weak var icon: UIImageView!
    @IBOutlet weak var temperature: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
    
        //On peut donc utiliser les fonctions rappels qu'on a défini suivant
        locationManger.delegate = self
        
        //Initialisation le meuilleur Accuracy
        locationManger.desiredAccuracy = kCLLocationAccuracyBest
        
        let background = UIImage(named: "111.jpg")
        self.view.backgroundColor = UIColor(patternImage:background!)

        
        if(ios11()) {
            locationManger.requestAlwaysAuthorization()
        }
       locationManger.startUpdatingLocation()
        }
    
    func ios11() -> Bool {
        return UIDevice.current.systemVersion >= "11.0"
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    public func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        var location:CLLocation = locations[locations.count-1]
        
        if(location.horizontalAccuracy > 0) {
            print(location.coordinate.latitude)
            print(location.coordinate.longitude)
            
            self.updateWeatherInfo(latitude: location.coordinate.latitude, longitude: location.coordinate.longitude)
            
            locationManger.stopUpdatingLocation()
        }
    }
    
    func updateWeatherInfo(latitude: CLLocationDegrees, longitude: CLLocationDegrees){
        Alamofire.request("http://api.openweathermap.org/data/2.5/weather?", parameters:  ["lat":latitude, "lon":longitude, "appid":"4f4be8fe7031dddd5dec789e01c1b3ac","cnt":0]).responseJSON { response in
            //print(response.request)
            //print(response.response)
            //print(response.data)
            print(response.result)
            
            if let JSON = response.result.value {
                print("JSON: \(JSON)")
                self.jsonResult = JSON as! NSDictionary
                self.updateUISuccess(jsonResult: self.jsonResult)
            }
        
        }
        
    }
    
    public func updateUISuccess(jsonResult:NSDictionary!) {
        if let mainResult = jsonResult["main"] as? [String: Any] {
            let tempResult = mainResult["temp"] as? Double
            var temperature: Double
            
            if let sysResult = jsonResult["sys"] as? [String: Any] {
                let countryResult = sysResult["country"] as? String
                if(countryResult == "US"){
                    //temperature = round((( tempResult! - 273.15) * 1.8) + 32)
                    temperature = round( tempResult! - 273.15)

                }
                else{
                    temperature = round( tempResult! - 273.15)
                }
                
                self.temperature.text = "\(temperature)"
                self.location.font = UIFont.boldSystemFont(ofSize: 60)

            }
            
            if let nameResult = jsonResult["name"] as? String {
                self.location.font = UIFont.boldSystemFont(ofSize: 25)
                self.location.text = "\(nameResult)"
            }
            
            var weather = jsonResult["weather"] as! [[String : Any]]
            var condition = weather[0]["id"] as? Int
            
            var sys = jsonResult["sys"] as! [String: Any]
            var sunrise = sys["sunrise"] as? Double
            var sunset = sys["sunset"] as? Double
            
            var nightTime = false
            var now = NSDate().timeIntervalSince1970
            
            if(now < sunrise! || now > sunset!){
                nightTime = true
            }
            self.updateWeatherIcon(condition: condition!, nightTime: nightTime)
        }else{
            
        }
    }
    
    func updateWeatherIcon(condition: Int, nightTime: Bool){
        if(condition < 300) {
            if nightTime {
                self.icon.image = UIImage(named: "tstorm1_night")
            }else{
                self.icon.image = UIImage(named: "tstorm1")
            }
        }
        else if (condition < 500) {
            self.icon.image = UIImage(named: "light_rain")
        }
        else if (condition < 600) {
            self.icon.image = UIImage(named: "shower3")
        }
        else if (condition < 700) {
            self.icon.image = UIImage(named: "snow4")
        }
        else if (condition < 771) {
            if nightTime {
                self.icon.image = UIImage(named: "fog_night")
            } else {
                self.icon.image = UIImage(named: "fog")
            }
        }
        else if (condition < 800) {
            self.icon.image = UIImage(named: "tstorm3")
        }
        else if (condition == 800){
            if (nightTime){
                self.icon.image = UIImage(named: "sunny_night")
            }else{
                self.icon.image = UIImage(named: "sunny")
            }
        }
        else if (condition < 804) {
            if(nightTime){
                self.icon.image = UIImage(named: "cloudy2_night")
            }else{
                self.icon.image = UIImage(named: "cloudy2")
            }
        }
        else if (condition == 804) {
            self.icon.image = UIImage(named: "overcast")
        }
        else if ((condition >= 900 && condition < 903)||(condition > 904 && condition < 1000)){
            self.icon.image = UIImage(named: "tstorm3")
        }
        else if (condition == 903) {
            self.icon.image = UIImage(named: "snow5")
        }
        else if (condition == 904) {
            self.icon.image = UIImage(named: "sunny")
        }
        else {
            self.icon.image = UIImage(named: "dunno")
        }
    }
    
    
    public func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print(error)
    }

    }

