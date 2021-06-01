import UIKit

class DailyTableViewCell: UITableViewCell {
    
    static let cellId = "dailyCell"

    @IBOutlet weak var dayOfWeekLabel: UILabel!
    
    @IBOutlet weak var popLabel: UILabel!
    
    @IBOutlet weak var maxTempLabel: UILabel!
    
    @IBOutlet weak var minTempLabel: UILabel!
    
    @IBOutlet weak var weatherIconImageView: UIImageView!
    
    lazy var dateFormatter: DateFormatter = {
        let dateFormatter = DateFormatter()
        dateFormatter.setLocalizedDateFormatFromTemplate("EEEE")
        
        return dateFormatter
    }()
    
    
    func update(with day: Daily) {
        dayOfWeekLabel.text = dateFormatter.string(from: Date(timeIntervalSince1970: Double(day.time ?? 0)))
        popLabel.text = "\(Int(day.pop ?? 99))%"
        maxTempLabel.text = "\(Int(day.temperature?.max ?? 99))"
        minTempLabel.text = "\(Int(day.temperature?.min ?? 99))"
        
    }
    
}
