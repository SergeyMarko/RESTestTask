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
        //collectionView.dataSource = self
        //collectionView.delegate = self
        
        let nib = UINib(nibName: String(describing: DailyTableViewCell.self), bundle: nil)
        tableView.register(nib, forCellReuseIdentifier: DailyTableViewCell.cellId)
    }
    
    
//    override func viewDidLayoutSubviews() {
//        super.viewDidLayoutSubviews()
//
//        let HEIGHT_VIEW = 128
////            tableView.tableFooterView?.frame.size = CGSize(width: tableView.frame.width, height: CGFloat(HEIGHT_VIEW))
//
//            tableView.tableHeaderView?.frame.size = CGSize(width:tableView.frame.width, height: CGFloat(HEIGHT_VIEW))
//
//        tableView.tableHeaderView = collectionView
//    }
    
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
    
//    func numberOfSections(in tableView: UITableView) -> Int {
//        1
//    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        dailyWeather?.count ?? 0
    }
    
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard
            let cell = tableView.dequeueReusableCell(withIdentifier: DailyTableViewCell.cellId, for: indexPath) as? DailyTableViewCell
        else {
            fatalError("Can not find cell with id: \(DailyTableViewCell.cellId) at indexPath: \(indexPath)")
        }
        
        if let day = dailyWeather?[indexPath.row] {
            cell.update(with: day)
        }
        
        return cell
    }
}


// MARK: - UITableViewDelegate

extension MainViewController: UITableViewDelegate {
    
    
    
}


// MARK: - UICollectionViewDataSource

//extension MainViewController: UICollectionViewDataSource {
//
//    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
//        hourlyWeather?.count ?? 0
//    }
//
//    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
//        <#code#>
//    }
//}


// MARK: - UICollectionViewDelegate

//extension MainViewController: UICollectionViewDelegate {
//    
//    
//}

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
                self.locationLabel.text = weatherInfo.timezone?.components(separatedBy: "/").last
                self.updateUI()
                self.tableView.reloadData()
            case .failure(let error):
                self.showErrorAlert(message: error.localizedDescription)
            }
        }
    }
}
