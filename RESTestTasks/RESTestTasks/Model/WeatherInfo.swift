import Foundation

struct WeatherInfo: Decodable {
    var timezone: String?
    var current: Current?
    var hourly: [Current]?
    var daily: [Daily]?
    
    enum CodingKeys: String, CodingKey {
        case timezone, current, hourly, daily
    }
}


struct Current: Decodable {
    var time: Int?
    var sunrise: Int?
    var sunset: Int?
    var temperature: Double?
    var feelsLike: Double?
    var pressure: Int?
    var humidity: Int?
    var uvi: Double?
    var clouds: Int?
    var visibility: Int?
    var windSpeed: Double?
    var weather: [Weather]?
    
    enum CodingKeys: String, CodingKey {
        case time = "dt"
        case temperature = "temp"
        case feelsLike = "feels_like"
        case windSpeed = "wind_speed"
        case sunrise, sunset, pressure, humidity, uvi, clouds, visibility, weather
    }
    
}


struct Daily: Decodable {
    var time: Int?
    var temperature: Temp?
    var pop: Double?
    var weather: [Weather]?
    
    enum CodingKeys: String, CodingKey {
        case time = "dt"
        case temperature = "temp"
        case pop, weather
    }
}


struct Weather: Decodable {
    var description: String?
    var icon: String?
    
    enum CodingKeys: String, CodingKey {
        case description, icon
    }
}


struct Temp: Decodable {
    var day: Double?
    var min: Double?
    var max: Double?
    var night: Double?
    
    enum CodingKeys: String, CodingKey {
        case day, min, max, night
    }
}
