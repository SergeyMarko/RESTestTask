import Foundation
import CoreLocation

enum DataError: Error {
    case loading(message: String = L10n.error.message.dataErrorLoading)
}

class NetworkManager {
    
    private let baseURL = "https://api.openweathermap.org/data/2.5/onecall?"
    
    private let exclude = "minutely,alerts"
    
    private let units = "metric"
    
    private let lang = "ru"
    
    private let apiKey = "aa40652bec44b833a29a637499750e47"
    
    private let apiKey2 = "07d32864d74dc24e0aeef218f7874880"
    
    private var allUrl = "https://api.openweathermap.org/data/2.5/onecall?lat=53.89&lon=27.56&lang=ru&units=metric&exclude=minutely,alerts&appid=07d32864d74dc24e0aeef218f7874880"
    
    func loadWeatherData(by location: CLLocationCoordinate2D, completionHandler: @escaping ((Result<WeatherInfo, Error>) -> Void) ) -> Void {
        
        guard
            let url = URL(string: "\(baseURL)lat=\(location.latitude)&lon=\(location.longitude)&lang=\(lang)&units=\(units)&exclude=\(exclude)&appid=\(apiKey2)")
        else { return }
        
        let urlSession = URLSession(configuration: .default)
        
        let newDataTask = urlSession.dataTask(with: url) { (data, response, error) in
            
            func fireCompletion(_ resultInfo: Result<WeatherInfo, Error>) {
                DispatchQueue.main.async {
                    completionHandler(resultInfo)
                }
            }
            
            if let error = error {
                fireCompletion(.failure(error))
            }
            
            guard let data = data else {
                let dataLoadingError = DataError.loading()
                fireCompletion(.failure(dataLoadingError))
                return
            }
            
            do {
                let resultInfo = try JSONDecoder().decode(WeatherInfo.self, from: data)
                fireCompletion(.success(resultInfo))
            } catch let parsingError {
                fireCompletion(.failure(parsingError))
            }
        }
        newDataTask.resume()
    }
}
