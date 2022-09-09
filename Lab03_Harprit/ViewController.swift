//
//  ViewController.swift
//  Lab03_Harprit
//
//  Created by Harprit on 2022-07-18.
//

import UIKit
import CoreLocation

class ViewController: UIViewController, UITextFieldDelegate {
    
    
    @IBOutlet weak var labelCondition: UILabel!
    @IBOutlet weak var tfLocationSearch: UITextField!
    private let locationManager = CLLocationManager()
    
    @IBOutlet weak var ivWeatherCondition: UIImageView!
    
    @IBOutlet weak var labelTemprature: UILabel!
    
    @IBOutlet weak var labelLocation: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        displaySampleImage(icon: "cloud.drizzle.fill")
        tfLocationSearch.delegate = self
        locationManager.delegate = self
        
    }
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.endEditing(true)
        print(textField.text ?? "")
        let query = textField.text
        loadWeather(search: query)
        return true
    }
    
    private func displaySampleImage(icon: String){
        let config = UIImage.SymbolConfiguration(paletteColors: [.systemYellow,.systemMint,.systemPink])
        DispatchQueue.main.async {
            self.ivWeatherCondition.preferredSymbolConfiguration = config
            self.ivWeatherCondition.image = UIImage(systemName: icon)
        }}
    @IBAction func onLocationTapped(_ sender: UIButton) {
        
        locationManager.requestWhenInUseAuthorization()
        locationManager.requestLocation()
        
    }
    
    private func changeBackgroundColor(color : UIColor){
        DispatchQueue.main.async {
            self.view.backgroundColor = color
        }
    }
    
    @IBAction func onSearch(_ sender: UIButton) {
        
        loadWeather(search: tfLocationSearch.text)
        
    }
    
    
    private func loadWeather(search: String?){
        guard let search = search else {
            return
        }
        
        //step 1 get URL
        
        guard let url = getUrl(query: search) else{
            print("No URL found")
            return
        }
        
        let urlSession = URLSession.shared
        
        let dataTask = urlSession.dataTask(with: url) { data, response, error in
            print("Network call completion")
            
            guard error == nil else{
                print(error)
                return
            }
            
            guard let data = data else{
                print("No data received")
                return
            }
            
            //decode the data
            if let weatherResponse = self.parseJSON(data: data){
                
                
                switch(weatherResponse.current.condition.code){
                case 1000:
                    //sunny
                    let icon = "sun.max.fill"
                    self.displaySampleImage(icon: icon)
                    self.changeBackgroundColor(color: UIColor.orange)
                    break
                case 1003,1006,1009:
                    //Partly cloudy
                    let icon = "cloud.sun.fill"
                    self.displaySampleImage(icon: icon)
                    self.changeBackgroundColor(color:UIColor.brown)
                    break
                case 1030:
                    let icon = "humidity"
                    //mist
                    self.displaySampleImage(icon: icon)
                    self.changeBackgroundColor(color:UIColor.lightGray)
                    
                    break
                case 1276,1273,1279,1282:
                    let icon = "cloud.bolt.rain"
                    //thunder
                    self.displaySampleImage(icon: icon)
                    self.changeBackgroundColor(color:UIColor.darkGray)
                    break
                case 1063,1069,1072,1087,1117,1150,1153,1168,1171,1180,1183,1186,1189,1192,1195,1198,1201,1240,1243,1246,1255,1258:
                    let icon = "cloud.drizzle.fill"
                    self.displaySampleImage(icon: icon)
                    //rain
                    self.changeBackgroundColor(color:UIColor.darkGray)
                    
                    break
                case 1066,1114,1210,1213,1216,1219,1222,1225,1237:
                    let icon = "snowflake"
                    //snow
                    self.displaySampleImage(icon: icon)
                    self.changeBackgroundColor(color:UIColor.lightGray)
                    
                    break
                case 1135,1147:
                    //fog
                    let icon = "cloud.fog.fill"
                    self.displaySampleImage(icon: icon)
                    self.changeBackgroundColor(color:UIColor.brown)
                    
                    break
                case 1204,1207,1249,1252,1261,1264:
                    let icon = "cloud.sleet"
                    //rain snow
                    self.displaySampleImage(icon: icon)
                    self.changeBackgroundColor(color:UIColor.cyan)
                    
                    break
                default:
                    let icon = "cloud.fill"
                    self.displaySampleImage(icon: icon)
                    self.changeBackgroundColor(color:UIColor.gray)
                    
                    break
                }
                
                DispatchQueue.main.async {
                    self.labelLocation.text = weatherResponse.location.name
                    self.labelTemprature.text = "\(weatherResponse.current.temp_c)C"
                    self.labelCondition.text = weatherResponse.current.condition.text
                }
            }
            
        }
        dataTask.resume()
    }
    
    private func parseJSON(data : Data) -> WeatherResponse?{
        let decoder = JSONDecoder()
        var weather : WeatherResponse?
        do{
            weather = try decoder.decode(WeatherResponse.self, from: data)
        }catch{
            print("Error decoding")
        }
        return weather
    }
    
    private func getUrl(query : String)-> URL?{
        
        
        let baseUrl = "https://api.weatherapi.com/v1/"
        let currentEndPoints = "current.json"
        let apiKey = "bd23a3c0dd0b41d990340022221907"
        guard let url = "\(baseUrl)\(currentEndPoints)?key=\(apiKey)&q=\(query)"
            .addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) else{
            return nil
        }
        
        print(url)
        
        return URL(string: url)
    }
    
    struct WeatherResponse: Decodable{
        let location : Location
        let current : Weather
    }
    
    struct Location : Decodable{
        let name : String
    }
    
    struct Weather: Decodable{
        let temp_c : Float
        let condition : WeatherCondition
    }
    
    struct WeatherCondition : Decodable{
        let text: String
        let code : Int
    }
}
extension ViewController : CLLocationManagerDelegate{
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        
        if let location = locations.last{
            let latitude = location.coordinate.latitude
            let longitude = location.coordinate.longitude
            print("(Lat \(latitude),Lng \(longitude))")
            loadWeather(search: "\(latitude),\(longitude)")
            
        }
        
    }
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print(error)
    }
}
