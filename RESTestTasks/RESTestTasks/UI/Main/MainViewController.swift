import UIKit
import CoreLocation

class MainViewController: UIViewController {
    
    // MARK: - Outlets

    @IBOutlet weak var locationLabel: UILabel!
    
    @IBOutlet weak var wetherDescription: UILabel!
    
    @IBOutlet weak var airTemperature: UILabel!
    
    @IBOutlet weak var maxMinTemperatureToday: UILabel!
    
    @IBOutlet weak var temperatureStackView: UIStackView!
    
    @IBOutlet weak var locationStackView: UIStackView!
    
    @IBOutlet weak var locationStackViewConstraintTop: NSLayoutConstraint!
    
    @IBOutlet weak var scrollView: UIScrollView!
    
    @IBOutlet weak var collectionView: UICollectionView!
    
    @IBOutlet weak var tableView: UITableView!
    
    private let locationManager = CLLocationManager()
    
    private var userLocationCoordinate: CLLocationCoordinate2D?
    
    private let networkManager = NetworkManager()
    
    private var currentWeather: Current?
    
    private var hourlyWeather: [Current]?
    
    private var dailyWeather: [Daily]?
    
    // MARK: - Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        locationManager.requestAlwaysAuthorization()
        locationManager.delegate = self
        
        if CLLocationManager.locationServicesEnabled() {
            locationManager.desiredAccuracy = kCLLocationAccuracyHundredMeters
            locationManager.startUpdatingLocation()
            
        }
        
        scrollView.delegate = self
        tableView.dataSource = self
        tableView.delegate = self
        
        let nib = UINib(nibName: String(describing: MainTableViewCell.self), bundle: nil)
        tableView.register(nib, forCellReuseIdentifier: MainTableViewCell.cellID)
    }
    
    // MARK: - Private
    
    private func updateUI() {
        guard
            let max = dailyWeather?.first?.temperature?.max,
            let min = dailyWeather?.first?.temperature?.min,
            let currentTemp = currentWeather?.temperature,
            let wetherDescription = currentWeather?.weather?.first?.description
        else { return }
        
        self.wetherDescription.text = wetherDescription
        airTemperature.text = String(Int(currentTemp))
        maxMinTemperatureToday.text = "Макс. \(Int(max)), мин. \(Int(min))"
    }

}

// MARK: - UITableViewDataSource

extension MainViewController: UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        20
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard
            let cell = tableView.dequeueReusableCell(withIdentifier: MainTableViewCell.cellID, for: indexPath) as? MainTableViewCell
        else {
            fatalError("Can not find cell with id: \(MainTableViewCell.cellID) at indexPath: \(indexPath)")
        }
        
        cell.titleLabel.text = "Восход солнца"
        cell.infoWetherLabel.text = "04:45"
        
        return cell
    }
    
    
    
}


// MARK: - UITableViewDelegate

extension MainViewController: UITableViewDelegate {
    
    
    
}

// MARK: - UIScrollViewDelegate

extension MainViewController: UIScrollViewDelegate {
    
    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {

        let contentOffset = locationStackView.frame.size.height + locationStackViewConstraintTop.constant


        scrollView.setContentOffset(CGPoint(x: 0, y: contentOffset), animated: true)
    }
}

// MARK: - CLLocationManagerDelegate

extension MainViewController: CLLocationManagerDelegate {
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let locValue: CLLocationCoordinate2D = manager.location?.coordinate else { return }
        
        networkManager.loadWeatherData(by: locValue) { [weak self] resalt in
            guard let self = self else { return }
            
            switch resalt {
            case .success(let weatherInfo):
                self.currentWeather = weatherInfo.current
                self.hourlyWeather = weatherInfo.hourly
                self.dailyWeather = weatherInfo.daily
                self.locationLabel.text = weatherInfo.timezone
                self.updateUI()
            case .failure(let error):
                self.showErrorAlert(message: error.localizedDescription)
            }
        }
    }
}
