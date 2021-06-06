import UIKit

class HourlyCollectionViewCell: UICollectionViewCell {
    
    // MARK: - Static
    
    static let cellId = "hourlyCell"
    
    // MARK: - Outlets
    
    @IBOutlet private weak var timeLabel: UILabel!
    @IBOutlet private weak var temperatureLabel: UILabel!
    @IBOutlet private weak var weatherIconImageView: UIImageView!
    
    // MARK: - Properties
    
    private var dataTask: URLSessionTask?
    private var cellTag = 0
    lazy var dateFormatter: DateFormatter = {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "HH"
        
        return dateFormatter
    }()
    
    // MARK: - Public
    
    func update(with weatherHourly: Current, cellTag: Int ) {
        self.cellTag = cellTag
        if cellTag == 0 {
            timeLabel.text = "Сейчас"
        } else {
            timeLabel.text = dateFormatter.string(from: Date(timeIntervalSince1970: Double(weatherHourly.time ?? 0)))
        }
        temperatureLabel.text = "\(Int(weatherHourly.temperature ?? 0))˚"
        
        loadIconWeather(with: weatherHourly, cellTag: cellTag)
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        
        dataTask?.cancel()
        dataTask = nil
        weatherIconImageView.image = nil
    }
    
    // MARK: - Private
    
    private func loadIconWeather(with weatherHourly: Current, cellTag: Int ) {
        self.dataTask?.cancel()
        
        guard
            let url = weatherHourly.urlIcon
        else { return }
        
        let session = URLSession(configuration: .default)
        let newDataTask = session.dataTask(with: url) { [weak self] (data, _, error) in
            guard
                let self = self,
                let data = data,
                error == nil,
                cellTag == self.cellTag
            else { return }
            
            var image: UIImage?
            image = UIImage(data: data)
            
            dispatchAsyncSafelyToMainQueue {
                self.weatherIconImageView.image = image
            }
        }
        self.dataTask? = newDataTask
        newDataTask.resume()
    }

}
