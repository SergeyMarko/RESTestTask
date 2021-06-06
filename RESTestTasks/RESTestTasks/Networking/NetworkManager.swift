import Foundation
import CoreLocation

enum DataError: Error {
    case loading(message: String = L10n.error.message.dataErrorLoading)
}

class NetworkManager {
    
    private struct Constant {
        static let baseURL = "https://api.openweathermap.org/data/2.5/onecall?"
        static let exclude = "minutely,alerts"
        static let units = "metric"
        static let lang = "ru"
        static let apiKey = "07d32864d74dc24e0aeef218f7874880"
    }
    

    
    func loadWeatherData(by location: CLLocationCoordinate2D, completionHandler: @escaping ((Result<WeatherInfo, Error>) -> Void) ) -> Void {
        
        guard let url = buildURL(for: location) else { return }
        
        let urlSession = URLSession(configuration: .default)
        
        let newDataTask = urlSession.dataTask(with: url) { (data, _, error) in
            
            guard
                let data = data,
                error == nil
            else {
                dispatchAsyncSafelyToMainQueue {
                    completionHandler(.failure(error ?? DataError.loading()))
                }
                return
            }
            
            do {
                let resultInfo = try JSONDecoder().decode(WeatherInfo.self, from: data)
                dispatchAsyncSafelyToMainQueue {
                    completionHandler(.success(resultInfo))
                }
            } catch let parsingError {
                dispatchAsyncSafelyToMainQueue {
                    completionHandler(.failure(parsingError))
                }
            }
        }
        newDataTask.resume()
    }
    
    
    private func buildURL(for location: CLLocationCoordinate2D) -> URL? {
        URL(string: "\(Constant.baseURL)lat=\(location.latitude)&lon=\(location.longitude)&lang=\(Constant.lang)&units=\(Constant.units)&exclude=\(Constant.exclude)&appid=\(Constant.apiKey)")
    }
}
