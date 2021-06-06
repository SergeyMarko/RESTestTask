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
    @IBOutlet weak var tableView: UITableView!
    
    // MARK: - Properties
    
    private var collectionView: UICollectionView!
    private let locationManager = CLLocationManager()
    private let networkManager = NetworkManager()
    private var userLocationCoordinate: CLLocationCoordinate2D?
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
        
        let nibDaily = UINib(nibName: String(describing: DailyTableViewCell.self), bundle: nil)
        tableView.register(nibDaily, forCellReuseIdentifier: DailyTableViewCell.cellId)
        
        configuerHeaderView()
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
    
    private func configuerHeaderView() {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .horizontal
        layout.sectionInset = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
        
        collectionView = UICollectionView(frame: CGRect(x: 0, y: 0, width: view.frame.width, height: 100), collectionViewLayout: layout)
        collectionView.backgroundColor = .clear
        collectionView.isPagingEnabled = true
        collectionView.isUserInteractionEnabled = true
        
        collectionView.dataSource = self
        collectionView.delegate = self
        
        let nibHourly = UINib(nibName: String(describing: HourlyCollectionViewCell.self), bundle: nil)
        
        collectionView.register(nibHourly, forCellWithReuseIdentifier: HourlyCollectionViewCell.cellId)
        
        tableView.tableHeaderView = collectionView
    }

}

// MARK: - UITableViewDataSource

extension MainViewController: UITableViewDataSource {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        1
    }
    
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
            cell.update(with: day, cellTag: indexPath.row)
        }
        
        return cell
    }
}


// MARK: - UITableViewDelegate

extension MainViewController: UITableViewDelegate {
    
    
    
}


// MARK: - UICollectionViewDataSource

extension MainViewController: UICollectionViewDataSource {

    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        (hourlyWeather?.count ?? 0) - 24
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: HourlyCollectionViewCell.cellId, for: indexPath) as? HourlyCollectionViewCell
        else {
            fatalError("Can not find cell with id: \(HourlyCollectionViewCell.cellId) at indexPath: \(indexPath)")
        }
        
        if let hourly = hourlyWeather?[indexPath.row] {
            cell.update(with: hourly, cellTag: indexPath.row)
        }
        
        return cell
    }
}


 //MARK: - UICollectionViewDelegate

extension MainViewController: UICollectionViewDelegateFlowLayout {
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        
        let itemsPerRow: CGFloat = 7
        let paddingWidth = 20 * (itemsPerRow + 1)
        let availableWidth = collectionView.frame.width - paddingWidth
        let widthPerItem = availableWidth / itemsPerRow
        
        return CGSize(width: widthPerItem, height: collectionView.frame.height)
        
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        UIEdgeInsets(top: 0, left: 20, bottom: 0, right: 20)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        10
    }
}

// MARK: - UIScrollViewDelegate

//extension MainViewController: UIScrollViewDelegate {
//
//    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
//
//        let contentOffset = locationStackView.frame.size.height + locationStackViewConstraintTop.constant
//
//
//        scrollView.setContentOffset(CGPoint(x: 0, y: contentOffset), animated: true)
//    }
//}

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
                
                
//                if let lastIndex = weatherInfo.hourly?.lastIndex(where: { $0.time ?? 0 < weatherInfo.current?.sunset ?? 0 }) {
//                    let sunset = Current(sunset: weatherInfo.current?.sunset)
//                    self.hourlyWeather?.insert(sunset, at: lastIndex + 1)
//                }
                
                self.collectionView.reloadData()
                
            case .failure(let error):
                self.showErrorAlert(message: error.localizedDescription)
            }
        }
    }
}
