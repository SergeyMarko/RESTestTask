import UIKit

class DailyTableViewCell: UITableViewCell {
    
    static let cellId = "dailyCell"

    @IBOutlet weak var dayOfWeekLabel: UILabel!
    @IBOutlet weak var popLabel: UILabel!
    @IBOutlet weak var maxTempLabel: UILabel!
    @IBOutlet weak var minTempLabel: UILabel!
    @IBOutlet weak var weatherIconImageView: UIImageView!
    
    var dataTask: URLSessionTask?
    
    lazy var dateFormatter: DateFormatter = {
        let dateFormatter = DateFormatter()
        dateFormatter.setLocalizedDateFormatFromTemplate("EEEE")
        
        return dateFormatter
    }()
    
    
    func update(with day: Daily) {
        
        dayOfWeekLabel.text = dateFormatter.string(from: Date(timeIntervalSince1970: Double(day.time ?? 0)))
        popLabel.text = "\(Int(day.pop ?? 99))%"
        if Int(day.pop ?? 10) == 0 {
            popLabel.text = ""
        }
        maxTempLabel.text = "\(Int(day.temperature?.max ?? 99))"
        minTempLabel.text = "\(Int(day.temperature?.min ?? 99))"
        
        func loadIconWeather() {
            self.dataTask?.cancel()
            
            guard
                let url = URL(string: "https://openweathermap.org/img/wn/\(day.weather?.first?.icon ?? "")@2x.png")
            else { return }
            
            let session = URLSession(configuration: .default)
            let newDataTask = session.dataTask(with: url) { [weak self] (data, _, error) in
                guard
                    let self = self,
                    let data = data,
                    error == nil
                else { return }
                
                var image: UIImage?
                image = UIImage(data: data)
                
                DispatchQueue.main.async {
                    self.weatherIconImageView.image = image
                }
            }
            self.dataTask? = newDataTask
            newDataTask.resume()
        }
        
        loadIconWeather()
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        
        dataTask?.cancel()
        dataTask = nil
        weatherIconImageView.image = nil
        textLabel?.text = nil
    }
    
}
