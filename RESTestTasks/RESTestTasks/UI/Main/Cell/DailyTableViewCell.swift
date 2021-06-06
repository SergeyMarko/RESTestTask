import UIKit

class DailyTableViewCell: UITableViewCell {
    
    //MARK: - Static
    
    static let cellId = "dailyCell"
    
    //MARK: - Outlets

    @IBOutlet private weak var dayOfWeekLabel: UILabel!
    @IBOutlet private weak var popLabel: UILabel!
    @IBOutlet private weak var maxTempLabel: UILabel!
    @IBOutlet private weak var minTempLabel: UILabel!
    @IBOutlet private weak var weatherIconImageView: UIImageView!
    
    //MARK: - Properties
    
    private var dataTask: URLSessionTask?
    private var cellTag = 0
    private lazy var dateFormatter: DateFormatter = {
        let dateFormatter = DateFormatter()
        dateFormatter.setLocalizedDateFormatFromTemplate("EEEE")
        
        return dateFormatter
    }()
    
    //MARK: - Public
    
    func update(with day: Daily, cellTag: Int) {
        self.cellTag = cellTag
        guard
            let time = day.time,
            let pop = day.pop,
            let tempMax = day.temperature?.max,
            let tempMin = day.temperature?.min
        else { return }
        dayOfWeekLabel.text = dateFormatter.string(from: Date(timeIntervalSince1970: Double(time)))
        maxTempLabel.text = "\(Int(tempMax))"
        minTempLabel.text = "\(Int(tempMin))"
        
        if Int(pop) == 0 {
            popLabel.text = ""
        } else {
            popLabel.text = "\(Int(pop))%"
        }
        
        loadIconWeather(with: day, cellTag: cellTag)
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        
        dataTask?.cancel()
        dataTask = nil
        weatherIconImageView.image = nil
        textLabel?.text = nil
    }
    
    // MARK: - Private
    
    private func loadIconWeather(with day: Daily, cellTag: Int ) {
        self.dataTask?.cancel()
        
        guard
            let url = day.urlIcon
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
